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
import { HttpsError, onCall, onRequest } from 'firebase-functions/v2/https';
import { defineSecret, defineString } from 'firebase-functions/params';
import Stripe from 'stripe';
import { ErreurCommande, calculerCommande } from './commandes.js';
import { jetonsInvalides, notificationCommande, notificationMessage } from './notifications.js';
import {
  actionPaiementApresChangement, actionsEvenementStripe, commissionApplication,
  fraisPaiementMineur, notificationApresChangement, prevenirProALaCreation,
} from './paiements.js';

initializeApp();

// Données en Europe (RGPD) et plafond de coût.
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const EMAIL_ADMIN_INITIAL = defineString('EMAIL_ADMIN_INITIAL', {
  description: 'Adresse e-mail du compte Harambee qui deviendra le premier administrateur',
});

const REF_ADMINS = 'systeme/admins';

// Clés Stripe : secrets Firebase (jamais dans le dépôt).
// firebase functions:secrets:set STRIPE_SECRET_KEY / STRIPE_WEBHOOK_SECRET
const STRIPE_SECRET_KEY = defineSecret('STRIPE_SECRET_KEY');
const STRIPE_WEBHOOK_SECRET = defineSecret('STRIPE_WEBHOOK_SECRET');

let clientStripe;
function stripe() {
  clientStripe ??= new Stripe(STRIPE_SECRET_KEY.value());
  return clientStripe;
}

/** Adresse publique d'une fonction HTTP de ce projet. */
function urlFonction(nom) {
  const projet = process.env.GCLOUD_PROJECT ?? JSON.parse(process.env.FIREBASE_CONFIG ?? '{}').projectId;
  return `https://europe-west1-${projet}.cloudfunctions.net/${nom}`;
}

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

/** Erreur de commande : le code est aussi dans `details.code` pour l'app. */
function erreurCommande(statut, code, details = {}) {
  return new HttpsError(statut, code, { ...details, code });
}

/**
 * Crée une commande. Tous les montants sont recalculés ici à partir du
 * catalogue, des réglages du commerce et des tarifs (parametres/tarifs).
 */
export const creerCommande = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (requete) => {
  if (!requete.auth) throw new HttpsError('unauthenticated', 'Connexion requise.');
  const d = requete.data ?? {};
  const db = getFirestore();

  const docCommerce = await db.doc(`commerces/${d.commerceId}`).get();
  const commerce = docCommerce.data();
  if (!commerce || commerce.statut !== 'publie') {
    throw erreurCommande('not-found', 'commerce-introuvable');
  }
  if (commerce.proprietaire === requete.auth.uid) {
    throw erreurCommande('failed-precondition', 'propre-commerce');
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
      throw erreurCommande('failed-precondition', e.code, e.details);
    }
    throw e;
  }

  const telephone = String(d.telephone ?? '').trim().slice(0, 30);
  if (!telephone) throw erreurCommande('invalid-argument', 'telephone-requis');
  const profil = (await db.doc(`users/${requete.auth.uid}`).get()).data() ?? {};
  const maintenant = Timestamp.now();
  const ref = db.collection('commandes').doc();

  // Paiement par carte : intention de paiement Stripe vers le compte du commerce.
  let fraisPaiement = 0;
  let paiementIntent = null;
  if (d.methode === 'carte') {
    const compte = (await db.doc(`comptesStripe/${d.commerceId}`).get()).data();
    if (!compte?.compteId) throw erreurCommande('failed-precondition', 'carte-indisponible');
    const frais = fraisPaiementMineur(calcul.totalMineur, tarifs.paiementCarte);
    fraisPaiement = frais / 100;
    paiementIntent = await stripe().paymentIntents.create({
      amount: calcul.totalMineur,
      currency: calcul.devise.toLowerCase(),
      automatic_payment_methods: { enabled: true },
      application_fee_amount: commissionApplication(calcul, frais),
      transfer_data: { destination: compte.compteId },
      description: `Harambee · ${commerce.nom}`,
      metadata: { commandeId: ref.id, commerceId: d.commerceId },
    }, { idempotencyKey: `commande-${ref.id}` });
  }

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
    // Frais du prestataire de paiement (estimés ; frais exacts dans fraisPaiementReel).
    fraisPaiement,
    total: calcul.total,
    devise: calcul.devise,
    mode: d.mode,
    adresseLivraison: d.mode === 'livraison' ? {
      texte: String(d.adresse?.texte ?? '').slice(0, 300),
      geo: new GeoPoint(position.latitude, position.longitude),
      instructions: String(d.adresse?.instructions ?? '').slice(0, 300),
    } : null,
    telephoneClient: telephone,
    paiement: { methode: d.methode, statut: 'en_attente', reference: paiementIntent?.id ?? null },
    statut: 'nouvelle',
    historique: [{ statut: 'nouvelle', date: maintenant }],
    createdAt: maintenant,
    updatedAt: maintenant,
  });
  return {
    commandeId: ref.id,
    total: calcul.total,
    devise: calcul.devise,
    clientSecret: paiementIntent?.client_secret ?? null,
  };
});

/** Reprendre le paiement d'une commande par carte (le client a fermé la page de paiement). */
export const secretPaiement = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (requete) => {
  if (!requete.auth) throw new HttpsError('unauthenticated', 'Connexion requise.');
  const commande = (await getFirestore().doc(`commandes/${requete.data?.commandeId}`).get()).data();
  if (!commande || commande.clientId !== requete.auth.uid) {
    throw new HttpsError('not-found', 'commande-introuvable');
  }
  if (commande.paiement?.methode !== 'carte' || commande.paiement?.statut === 'paye'
    || commande.statut !== 'nouvelle' || !commande.paiement?.reference) {
    throw new HttpsError('failed-precondition', 'paiement-impossible');
  }
  const pi = await stripe().paymentIntents.retrieve(commande.paiement.reference);
  return { clientSecret: pi.client_secret };
});

/**
 * Le commerçant active le paiement par carte : compte Stripe « Express » créé
 * au besoin, puis lien vers le formulaire d'inscription de Stripe.
 */
export const lienPaiementCarte = onCall({ secrets: [STRIPE_SECRET_KEY] }, async (requete) => {
  if (!requete.auth) throw new HttpsError('unauthenticated', 'Connexion requise.');
  const commerceId = String(requete.data?.commerceId ?? '');
  const db = getFirestore();
  const commerce = (await db.doc(`commerces/${commerceId}`).get()).data();
  if (!commerce || commerce.proprietaire !== requete.auth.uid) {
    throw new HttpsError('permission-denied', 'Réservé au propriétaire du commerce.');
  }
  const refCompte = db.doc(`comptesStripe/${commerceId}`);
  let compteId = (await refCompte.get()).data()?.compteId;
  if (!compteId) {
    const compte = await stripe().accounts.create({
      type: 'express',
      country: commerce.pays || 'BE',
      email: requete.auth.token.email,
      business_profile: { name: commerce.nom },
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
        bancontact_payments: { requested: true },
      },
      metadata: { commerceId },
    }, { idempotencyKey: `compte-${commerceId}` });
    compteId = compte.id;
    await refCompte.set({ compteId, creeLe: FieldValue.serverTimestamp() });
  }
  const lien = await stripe().accountLinks.create({
    account: compteId,
    refresh_url: `${urlFonction('retourStripe')}?etat=expire`,
    return_url: `${urlFonction('retourStripe')}?etat=termine`,
    type: 'account_onboarding',
  });
  return { url: lien.url };
});

/** Page affichée après le formulaire Stripe. */
export const retourStripe = onRequest((requete, reponse) => {
  const termine = requete.query.etat === 'termine';
  reponse.set('Content-Type', 'text/html; charset=utf-8').send(`<!doctype html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Harambee</title>
<style>body{font-family:-apple-system,system-ui,sans-serif;background:#F6F1E7;color:#1E1B16;
display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;padding:24px;text-align:center}
h1{color:#B4451F;font-size:1.5rem}</style></head>
<body><main><h1>${termine ? 'Merci !' : 'Lien expiré'}</h1>
<p>${termine
    ? 'Vous pouvez fermer cette page et revenir dans l\'app Harambee. Le paiement par carte sera actif dès que Stripe aura validé vos informations.'
    : 'Revenez dans l\'app Harambee et touchez à nouveau « Activer le paiement par carte ».'}</p>
</main></body></html>`);
});

/** Événements envoyés par Stripe (paiements, comptes des commerces). */
export const stripeWebhook = onRequest(
  { secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET] },
  async (requete, reponse) => {
    // Deux destinations Stripe (votre compte, comptes connectés des commerces),
    // chacune avec son secret : STRIPE_WEBHOOK_SECRET = « whsec_A,whsec_B ».
    let evenement;
    for (const secret of STRIPE_WEBHOOK_SECRET.value().split(',').map((x) => x.trim()).filter(Boolean)) {
      try {
        evenement = stripe().webhooks.constructEvent(
          requete.rawBody, requete.get('stripe-signature'), secret);
        break;
      } catch {
        // Essayer le secret suivant.
      }
    }
    if (!evenement) {
      logger.warn('Webhook Stripe refusé (signature invalide)');
      reponse.status(400).send('Signature invalide');
      return;
    }
    const db = getFirestore();
    for (const action of actionsEvenementStripe(evenement)) {
      const donnees = { ...action.donnees };
      if (action.fraisReels) {
        const charge = await stripe().charges.retrieve(action.fraisReels, { expand: ['balance_transaction'] });
        const frais = charge.balance_transaction?.fee;
        if (frais != null) donnees.fraisPaiementReel = frais / 100;
      }
      try {
        await db.doc(`${action.collection}/${action.id}`).update(donnees);
      } catch (e) {
        if (e.code !== 5) throw e; // document supprimé : rien à faire
      }
    }
    reponse.json({ recu: true });
  },
);

/** Commande par carte annulée ou refusée : remboursement ou annulation du paiement. */
export const gererPaiementCommande = onDocumentUpdated(
  { document: 'commandes/{commandeId}', secrets: [STRIPE_SECRET_KEY] },
  async (evenement) => {
    const avant = evenement.data?.before.data();
    const apres = evenement.data?.after.data();
    const action = actionPaiementApresChangement(avant, apres);
    const pi = apres?.paiement?.reference;
    if (!action || !pi) return;
    if (process.env.FUNCTIONS_EMULATOR === 'true') {
      logger.info('Émulateur : pas d\'appel à Stripe', { action, pi });
      return;
    }
    if (action === 'rembourser') {
      await stripe().refunds.create(
        { payment_intent: pi, reverse_transfer: true, refund_application_fee: true },
        { idempotencyKey: `remboursement-${evenement.params.commandeId}` },
      );
    } else {
      await stripe().paymentIntents.cancel(pi);
      await evenement.data.after.ref.update({ 'paiement.statut': 'echoue' });
    }
  },
);

/** Prévient le commerçant d'une nouvelle commande. */
export const notifierNouvelleCommande = onDocumentCreated('commandes/{commandeId}', async (evenement) => {
  const commande = evenement.data?.data();
  if (!commande || !prevenirProALaCreation(commande)) return;
  await envoyerNotification(commande.proId, (langue) =>
    notificationCommande({ commandeId: evenement.params.commandeId, commande, pourPro: true, langue }));
});

/** Prévient le client à chaque étape de sa commande. */
export const notifierSuiviCommande = onDocumentUpdated('commandes/{commandeId}', async (evenement) => {
  const avant = evenement.data?.before.data();
  const apres = evenement.data?.after.data();
  const cible = notificationApresChangement(avant, apres);
  if (!cible) return;
  await envoyerNotification(cible.uid, (langue) =>
    notificationCommande({
      commandeId: evenement.params.commandeId, commande: apres, pourPro: cible.pourPro, langue,
    }));
});
