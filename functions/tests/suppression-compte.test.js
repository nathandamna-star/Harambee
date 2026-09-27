import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut } from 'firebase/auth';
import { connectFirestoreEmulator, doc, getDoc, getFirestore, setDoc } from 'firebase/firestore';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJET = 'demo-harambee';
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'suppression');
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);
const supprimer = httpsCallable(fonctions, 'supprimerMonCompte');

const appAdmin = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'admin-suppression');
const db = getFirestore(appAdmin);
connectFirestoreEmulator(db, '127.0.0.1', 8080, { mockUserToken: 'owner' });

async function vider() {
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

const existe = async (chemin) => (await getDoc(doc(db, chemin))).exists();

after(async () => {
  await signOut(auth);
  await deleteApp(app);
  await deleteApp(appAdmin);
});

describe('suppression du compte (émulateur)', () => {
  beforeEach(vider);

  it('client : données supprimées, commandes terminées anonymisées', async () => {
    const { user } = await createUserWithEmailAndPassword(auth, 'awa@exemple.com', 'motdepasse1');
    const uid = user.uid;
    await setDoc(doc(db, `users/${uid}`), { nom: 'Awa', role: 'client' });
    await setDoc(doc(db, 'commerces/mama'), { nom: 'Chez Mama', proprietaire: 'pro1', statut: 'publie' });
    await setDoc(doc(db, `commerces/mama/avis/${uid}`), { auteur: uid, note: 5 });
    await setDoc(doc(db, 'signalements/s1'), { auteur: uid, cible: 'commerce' });
    await setDoc(doc(db, `conversations/mama__${uid}`), { participants: [uid, 'pro1'] });
    await setDoc(doc(db, `conversations/mama__${uid}/messages/m1`), { auteur: uid, texte: 'Bonjour' });
    await setDoc(doc(db, 'commandes/c1'), {
      clientId: uid, clientNom: 'Awa', telephoneClient: '0470', proId: 'pro1', statut: 'retiree', total: 10,
    });

    await supprimer();

    assert.equal(await existe(`users/${uid}`), false);
    assert.equal(await existe(`commerces/mama/avis/${uid}`), false);
    assert.equal(await existe('signalements/s1'), false);
    assert.equal(await existe(`conversations/mama__${uid}`), false);
    assert.equal(await existe(`conversations/mama__${uid}/messages/m1`), false);
    assert.equal(await existe('commerces/mama'), true);
    const commande = (await getDoc(doc(db, 'commandes/c1'))).data();
    assert.equal(commande.clientId, 'compte-supprime');
    assert.equal(commande.clientNom, '');
    assert.equal(commande.telephoneClient, '');
    assert.equal(commande.total, 10);
  });

  it('commerçant : commerces, produits et lien Stripe supprimés', async () => {
    const { user } = await createUserWithEmailAndPassword(auth, 'mama@exemple.com', 'motdepasse1');
    const uid = user.uid;
    await setDoc(doc(db, `users/${uid}`), { nom: 'Mama', role: 'pro' });
    await setDoc(doc(db, 'commerces/mama'), { nom: 'Chez Mama', proprietaire: uid, statut: 'publie' });
    await setDoc(doc(db, 'commerces/mama/produits/p1'), { nom: 'Attiéké' });
    await setDoc(doc(db, 'comptesStripe/mama'), { compteId: 'acct_1' });
    await setDoc(doc(db, 'commandes/c1'), { clientId: 'x', proId: uid, statut: 'livree', total: 10 });

    await supprimer();

    assert.equal(await existe('commerces/mama'), false);
    assert.equal(await existe('commerces/mama/produits/p1'), false);
    assert.equal(await existe('comptesStripe/mama'), false);
    assert.equal(await existe('commandes/c1'), true);
  });

  it('refusée tant qu\'une commande est en cours', async () => {
    const { user } = await createUserWithEmailAndPassword(auth, 'kofi@exemple.com', 'motdepasse1');
    await setDoc(doc(db, `users/${user.uid}`), { nom: 'Kofi', role: 'client' });
    await setDoc(doc(db, 'commandes/c1'), { clientId: user.uid, proId: 'pro1', statut: 'acceptee' });
    await assert.rejects(supprimer(), (e) => e.details?.code === 'commandes-en-cours');
    assert.equal(await existe(`users/${user.uid}`), true);
  });

  it('sans connexion : refusée', async () => {
    await signOut(auth);
    await assert.rejects(supprimer(), (e) => e.code === 'functions/unauthenticated');
  });
});
