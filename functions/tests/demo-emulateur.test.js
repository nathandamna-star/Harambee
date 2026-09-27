import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut } from 'firebase/auth';
import {
  collection, connectFirestoreEmulator, doc, getDoc, getDocs, getFirestore, query, setDoc, where,
} from 'firebase/firestore';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJET = 'demo-harambee';
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'demo');
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);
const revendiquer = httpsCallable(fonctions, 'revendiquerAdminInitial');
const charger = httpsCallable(fonctions, 'chargerDemo');
const supprimer = httpsCallable(fonctions, 'supprimerDemo');

const appAdmin = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'admin-demo');
const db = getFirestore(appAdmin);
connectFirestoreEmulator(db, '127.0.0.1', 8080, { mockUserToken: 'owner' });

after(async () => {
  await signOut(auth);
  await deleteApp(app);
  await deleteApp(appAdmin);
});

describe('données de démonstration (émulateur)', () => {
  beforeEach(async () => {
    await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
    await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
  });

  it('réservé aux administrateurs', async () => {
    await createUserWithEmailAndPassword(auth, 'quelquun@exemple.com', 'motdepasse1');
    await assert.rejects(charger(), (e) => e.code === 'functions/permission-denied');
    await assert.rejects(supprimer(), (e) => e.code === 'functions/permission-denied');
  });

  it('chargement puis suppression complète, sans toucher aux vrais commerces', async () => {
    const admin = await createUserWithEmailAndPassword(auth, 'premier-admin@exemple.com', 'motdepasse1');
    await revendiquer();
    await admin.user.getIdToken(true);
    await setDoc(doc(db, 'commerces/vrai'), { nom: 'Vrai commerce', statut: 'publie' });

    const r = await charger();
    assert.equal(r.data.commerces, 10);
    const demo = await getDocs(query(collection(db, 'commerces'), where('demo', '==', true)));
    assert.equal(demo.size, 10);
    const awa = (await getDoc(doc(db, 'commerces/demo-maquis-chez-awa'))).data();
    assert.equal(awa.statut, 'publie');
    assert.equal(awa.photos.length, 1);
    assert.equal((await getDocs(collection(db, 'commerces/demo-maquis-chez-awa/produits'))).size, 5);

    await setDoc(doc(db, 'commandes/c1'), { commerceId: 'demo-maquis-chez-awa', statut: 'nouvelle' });
    const s = await supprimer();
    assert.equal(s.data.commerces, 10);
    assert.equal((await getDocs(query(collection(db, 'commerces'), where('demo', '==', true)))).size, 0);
    assert.equal((await getDoc(doc(db, 'commandes/c1'))).exists(), false);
    assert.equal((await getDoc(doc(db, 'commerces/vrai'))).exists(), true);
  });
});
