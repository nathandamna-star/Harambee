// Fonctions serveur Harambee.
// Elles s'exécutent avec les droits du SDK Admin, hors règles de sécurité :
// chaque fonction vérifie elle-même qui l'appelle.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getMessaging } from 'firebase-admin/messaging';
import { AggregateField, FieldValue, GeoPoint, Timestamp, getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { logger } from 'firebase-functions';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { defineString } from 'firebase-functions/params';
import { ErreurCommande, calculerCommande } from './commandes.js';
import { jetonsInvalides, notificationCommande, notificationMessage } from './notifications.js';

initializeApp();

// Données en Europe (RGPD) et plafond de coût.
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const EMAIL_ADMIN_INITIAL = defineString('EMAIL_ADMIN_INITIAL', {
  description: 'Adresse e-mail du compte Harambee qui deviendra le premier administrateur',
});

const REF_ADMINS = 'systeme/admins';

function emailNormalise(valeur) {
  return (valeur ?? '').trim().toLowerCase();
}

/**
 * Le tout premier administrateur : le compte dont l'e-mail a été indiqué au
 * déploiement. Ne fonctionne qu'une fois ; ensuite, seuls les administrateurs
 * nomment d'autres administrateurs (voir definirAdmin).
 */
export const revendiquerAdminInitial = onCall(async (requete) => {
  if (!requete.auth) {
    throw new HttpsError('unauthenticated', 'Connexion requise.');
  }
  const attendu = emailNormalise(EMAIL_ADMIN_INITIAL.value());
  const email = emailNormalise(requete.auth.token.email);
  if (!attendu || email !== attendu) {
    throw new HttpsError('permission-denied', 'Ce compte ne peut pas devenir administrateur.');
  }

  const uid = requete.auth.uid;
  const db = getFirestore();
  await db.runTransaction(async (t) => {
    const ref = db.doc(REF_ADMINS);
    const doc = await t.get(ref);
    if (doc.exists && doc.data().premierAdmin !== uid) {
      throw new HttpsError('failed-precondition', 'Le premier administrateur est déjà désigné.');
    }
    t.set(ref, { premierAdmin: uid, designeLe: FieldValue.serverTimestamp() }, { merge: true });
  });

  await definirClaimAdmin(uid, true);
  await journaliser(uid, uid, email, true);
  return { admin: true };
});

/**
 * Nomme ou retire un administrateur, par son adresse e-mail.
 * Réservé aux administrateurs.
 */
export const definirAdmin = onCall(async (requete) => {
  if (requete.auth?.token.admin !== true) {
    throw new HttpsError('permission-denied', 'Réservé aux administrateurs.');
  }
  const email = emailNormalise(requete.data?.email);
  const admin = requete.data?.admin === true;
  if (!email) {
    throw new HttpsError('invalid-argument', 'Adresse e-mail manquante.');
  }

  let cible;
  try {
    cible = await getAuth().getUserByEmail(email);
  } catch {
    throw new HttpsError('not-found', 'Aucun compte avec cette adresse.');
  }
  if (cible.uid === requete.auth.uid && !admin) {
    throw new HttpsError('failed-precondition', 'Vous ne pouvez pas retirer votre propre accès.');
  }

  await definirClaimAdmin(cible.uid, admin);
  await journaliser(requete.auth.uid, cible.uid, email, admin);
  return { uid: cible.uid, admin };
});

async function definirClaimAdmin(uid, admin) {
  const auth = getAuth();
  const { customClaims = {} } = await auth.getUser(uid);
  const claims = { ...customClaims };
  if (admin) {
    claims.admin = true;
  } else {
    delete claims.admin;
  }
  await auth.setCustomUserClaims(uid, claims);
}

async function journaliser(par, cible, email, admin) {
  await getFirestore().collection(`${REF_ADMINS}/historique`).add({
    par, cible, email, admin, le: FieldValue.serverTimestamp(),
  });
}

/**
 * Recalcule la note moyenne et le nombre d'avis d'un commerce à chaque
 * création, modification ou suppression d'avis. L'app ne peut pas écrire ces
 * champs elle-même (règles Firestore).
 */
export const recalculerNote = onDocumentWritten(
  'commerces/{commerceId}/avis/{auteurId}',
  async (evenement) => {
    const db = getFirestore();
    const refCommerce = db.doc(`commerces/${evenement.params.commerceId}`);
    const stats = await refCommerce
      .collection('avis')
      .aggregate({ nb: AggregateField.count(), moyenne: AggregateField.average('note') })
      .get();
    const { nb, moyenne } = stats.data();
    try {
      await refCommerce.update({
        nbAvis: nb,
        noteMoyenne: nb === 0 ? 0 : Math.round((moyenne ?? 0) * 10) / 10,
      });
    } catch (e) {
      // Commerce supprimé entre-temps : rien à mettre à jour.
      if (e.code !== 5) throw e;
    }
  },
);

/**
 * Notifie le destinataire d'un nouveau message sur tous ses téléphones.
 */
export const notifierMessage = onDocumentCreated(
  'conversations/{conversationId}/messages/{messageId}',
  async (evenement) => {
    const db = getFirestore();
    const { conversationId } = evenement.params;
    const conversation = (await db.doc(`conversations/${conversationId}`).get()).data();
    const message = evenement.data?.data();
    if (!conversation || !message) return;

    const premier = notificationMessage({ conversationId, conversation, message, langue: 'fr' });
    if (!premier) return;
    await envoyerNotification(premier.destinataire, (langue) =>
      notificationMessage({ conversationId, conversation, message, langue }));
  },
);

/**
 * Envoie une notification sur tous les téléphones de [uid], dans sa langue.
 * [construire] reçoit la langue et renvoie { notification, data }.
 */
async function envoyerNotification(uid, construire) {
  const refProfil = getFirestore().doc(`users/${uid}`);
  const profil = (await refProfil.get()).data() ?? {};
  const jetons = profil.jetonsNotif ?? [];
  if (jetons.length === 0) return;
  const { notification, data } = construire(profil.langue);
  if (process.env.FUNCTIONS_EMULATOR === 'true') {
    logger.info('Émulateur : notification non envoyée', { uid, notification });
    return;
  }
  const resultat = await getMessaging().sendEachForMulticast({
    tokens: jetons,
    notification,
    data,
    apns: { payload: { aps: { sound: 'default' } } },
  });
  const invalides = jetonsInvalides(jetons, resultat.responses);
  if (invalides.length > 0) {
    await refProfil.update({ jetonsNotif: FieldValue.arrayRemove(...invalides) });
  }
}

/**
 * Crée une commande. Tous les montants sont recalculés ici à partir du
 * catalogue, des réglages du commerce et des tarifs (parametres/tarifs).
 */
export const creerCommande = onCall(async (requete) => {
  if (!requete.auth) throw new HttpsError('unauthenticated', 'Connexion requise.');
  const d = requete.data ?? {};
  const db = getFirestore();

  const docCommerce = await db.doc(`commerces/${d.commerceId}`).get();
  const commerce = docCommerce.data();
  if (!commerce || commerce.statut !== 'publie') {
    throw new HttpsError('not-found', 'commerce-introuvable');
  }
  if (commerce.proprietaire === requete.auth.uid) {
    throw new HttpsError('failed-precondition', 'propre-commerce');
  }

  const lignes = Array.isArray(d.lignes) ? d.lignes.slice(0, 50) : [];
  const refsProduits = lignes.map((l) => db.doc(`commerces/${d.commerceId}/produits/${String(l.produitId)}`));
  const docsProduits = refsProduits.length ? await db.getAll(...refsProduits) : [];
  const produits = Object.fromEntries(docsProduits.filter((x) => x.exists).map((x) => [x.id, x.data()]));
  const tarifs = (await db.doc('parametres/tarifs').get()).data();

  const position = d.adresse?.latitude != null
    ? { latitude: Number(d.adresse.latitude), longitude: Number(d.adresse.longitude) }
    : null;
  let calcul;
  try {
    calcul = calculerCommande({
      commerce: { ...commerce, createdAt: commerce.createdAt?.toDate?.() ?? null },
      produits,
      lignes,
      mode: d.mode,
      methode: d.methode,
      positionLivraison: position,
      tarifs: tarifs && {
        ...tarifs,
        lancement: tarifs.lancement && {
          ...tarifs.lancement,
          inscritsAvant: tarifs.lancement.inscritsAvant?.toDate?.() ?? null,
        },
      },
      maintenant: new Date(),
    });
  } catch (e) {
    if (e instanceof ErreurCommande) {
      throw new HttpsError('failed-precondition', e.code, e.details);
    }
    throw e;
  }

  const telephone = String(d.telephone ?? '').trim().slice(0, 30);
  if (!telephone) throw new HttpsError('invalid-argument', 'telephone-requis');
  const profil = (await db.doc(`users/${requete.auth.uid}`).get()).data() ?? {};
  const maintenant = Timestamp.now();

  const ref = db.collection('commandes').doc();
  await ref.set({
    commerceId: d.commerceId,
    commerceNom: commerce.nom,
    clientId: requete.auth.uid,
    clientNom: profil.nom ?? '',
    proId: commerce.proprietaire,
    pays: commerce.pays ?? null,
    lignes: calcul.lignes,
    sousTotal: calcul.sousTotal,
    fraisLivraison: calcul.fraisLivraison,
    fraisService: calcul.fraisService,
    commissionPlateforme: calcul.commissionPlateforme,
    // Frais du prestataire de paiement : connus après un paiement par carte.
    fraisPaiement: 0,
    total: calcul.total,
    devise: calcul.devise,
    mode: d.mode,
    adresseLivraison: d.mode === 'livraison' ? {
      texte: String(d.adresse?.texte ?? '').slice(0, 300),
      geo: new GeoPoint(position.latitude, position.longitude),
      instructions: String(d.adresse?.instructions ?? '').slice(0, 300),
    } : null,
    telephoneClient: telephone,
    paiement: { methode: d.methode, statut: 'en_attente', reference: null },
    statut: 'nouvelle',
    historique: [{ statut: 'nouvelle', date: maintenant }],
    createdAt: maintenant,
    updatedAt: maintenant,
  });
  return { commandeId: ref.id, total: calcul.total, devise: calcul.devise };
});

/** Prévient le commerçant d'une nouvelle commande. */
export const notifierNouvelleCommande = onDocumentCreated('commandes/{commandeId}', async (evenement) => {
  const commande = evenement.data?.data();
  if (!commande) return;
  await envoyerNotification(commande.proId, (langue) =>
    notificationCommande({ commandeId: evenement.params.commandeId, commande, pourPro: true, langue }));
});

/** Prévient le client à chaque étape de sa commande. */
export const notifierSuiviCommande = onDocumentUpdated('commandes/{commandeId}', async (evenement) => {
  const avant = evenement.data?.before.data();
  const apres = evenement.data?.after.data();
  if (!avant || !apres || avant.statut === apres.statut) return;
  // Le client qui annule n'a pas besoin d'être prévenu ; le commerçant, si.
  const pourPro = apres.statut === 'annulee';
  await envoyerNotification(pourPro ? apres.proId : apres.clientId, (langue) =>
    notificationCommande({ commandeId: evenement.params.commandeId, commande: apres, pourPro, langue }));
});
