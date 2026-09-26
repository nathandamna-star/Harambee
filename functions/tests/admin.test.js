import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import {
  connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut,
} from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJET = 'demo-harambee';
const EMAIL_PREMIER = 'premier-admin@exemple.com';

const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' });
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);

const revendiquer = httpsCallable(fonctions, 'revendiquerAdminInitial');
const definirAdmin = httpsCallable(fonctions, 'definirAdmin');

async function viderEmulateurs() {
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

async function creerCompte(email) {
  const cred = await createUserWithEmailAndPassword(auth, email, 'motdepasse1');
  return cred.user;
}

async function estAdmin(user) {
  const jeton = await user.getIdTokenResult(true);
  return jeton.claims.admin === true;
}

async function refuse(promesse, code) {
  await assert.rejects(promesse, (e) => e.code === `functions/${code}`);
}

after(async () => { await signOut(auth); await deleteApp(app); });

describe('premier administrateur', () => {
  beforeEach(viderEmulateurs);

  it('le compte configuré devient administrateur', async () => {
    const user = await creerCompte(EMAIL_PREMIER);
    assert.equal(await estAdmin(user), false);
    await revendiquer();
    assert.equal(await estAdmin(user), true);
  });

  it('majuscules et espaces dans l\'e-mail sont tolérés', async () => {
    const user = await creerCompte('Premier-Admin@Exemple.com');
    await revendiquer();
    assert.equal(await estAdmin(user), true);
  });

  it('un autre compte est refusé', async () => {
    const user = await creerCompte('intrus@exemple.com');
    await refuse(revendiquer(), 'permission-denied');
    assert.equal(await estAdmin(user), false);
  });

  it('sans connexion : refusé', async () => {
    await signOut(auth);
    await refuse(revendiquer(), 'unauthenticated');
  });

  it('ne fonctionne qu\'une fois (un nouveau compte avec le même e-mail est refusé)', async () => {
    const premier = await creerCompte(EMAIL_PREMIER);
    await revendiquer();
    // Le compte est supprimé puis recréé avec la même adresse.
    await premier.delete();
    await creerCompte(EMAIL_PREMIER);
    await refuse(revendiquer(), 'failed-precondition');
  });

  it('peut être rappelé sans erreur par le même compte', async () => {
    await creerCompte(EMAIL_PREMIER);
    await revendiquer();
    await revendiquer();
  });
});

describe('nommer ou retirer un administrateur', () => {
  beforeEach(viderEmulateurs);

  it('un administrateur nomme puis retire un autre administrateur', async () => {
    await creerCompte('awa@exemple.com');
    await signOut(auth);
    const admin = await creerCompte(EMAIL_PREMIER);
    await revendiquer();
    await admin.getIdToken(true);

    const res = await definirAdmin({ email: 'awa@exemple.com', admin: true });
    assert.equal(res.data.admin, true);
    await definirAdmin({ email: 'awa@exemple.com', admin: false });
  });

  it('un non-administrateur ne peut nommer personne', async () => {
    await creerCompte('awa@exemple.com');
    await signOut(auth);
    await creerCompte('kofi@exemple.com');
    await refuse(definirAdmin({ email: 'kofi@exemple.com', admin: true }), 'permission-denied');
  });

  it('adresse inconnue ou vide', async () => {
    const admin = await creerCompte(EMAIL_PREMIER);
    await revendiquer();
    await admin.getIdToken(true);
    await refuse(definirAdmin({ email: 'personne@exemple.com', admin: true }), 'not-found');
    await refuse(definirAdmin({ email: '', admin: true }), 'invalid-argument');
  });

  it('on ne peut pas se retirer soi-même', async () => {
    const admin = await creerCompte(EMAIL_PREMIER);
    await revendiquer();
    await admin.getIdToken(true);
    await refuse(definirAdmin({ email: EMAIL_PREMIER, admin: false }), 'failed-precondition');
  });
});
