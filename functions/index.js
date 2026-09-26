// Fonctions serveur Harambee.
// Elles s'exécutent avec les droits du SDK Admin, hors règles de sécurité :
// chaque fonction vérifie elle-même qui l'appelle.
import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { setGlobalOptions } from 'firebase-functions/v2';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { defineString } from 'firebase-functions/params';

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
