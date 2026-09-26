import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut } from 'firebase/auth';
import {
  Timestamp, connectFirestoreEmulator, doc, getDoc, getFirestore, setDoc,
} from 'firebase/firestore';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';

const PROJET = 'demo-harambee';
const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'commande');
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
const fonctions = getFunctions(app, 'europe-west1');
connectFunctionsEmulator(fonctions, '127.0.0.1', 5001);
const creerCommande = httpsCallable(fonctions, 'creerCommande');

// Accès direct à la base (sans règles) pour préparer et vérifier.
const appAdmin = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'admin-commande');
const db = getFirestore(appAdmin);
connectFirestoreEmulator(db, '127.0.0.1', 8080, { mockUserToken: 'owner' });

async function vider() {
  await fetch(`http://127.0.0.1:9099/emulator/v1/projects/${PROJET}/accounts`, { method: 'DELETE' });
  await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
}

async function preparer() {
  await setDoc(doc(db, 'parametres/tarifs'), {
    defaut: { commissionPct: 6, fraisServiceFixe: 0.49 },
    parPays: { BE: { commissionPct: 7, fraisServiceFixe: 0.69 } },
  });
  await setDoc(doc(db, 'commerces/mama'), {
    nom: 'Chez Mama', statut: 'publie', proprietaire: 'pro1', pays: 'BE', continent: 'europe',
    createdAt: Timestamp.fromDate(new Date('2026-01-10')),
    commande: {
      active: true, modes: ['emporter', 'livraison'], minimumCommande: 10, minimumLivraison: 20,
      fraisLivraison: 3.5, rayonLivraisonKm: 5, especesAcceptees: true, devise: 'EUR',
    },
  });
  await setDoc(doc(db, 'commerces/mama/produits/a'), { nom: 'Attiéké', prix: 8.5, publie: true });
}

after(async () => {
  await signOut(auth);
  await deleteApp(app);
  await deleteApp(appAdmin);
});

describe('creerCommande (émulateur)', () => {
  beforeEach(async () => {
    await vider();
    await preparer();
  });

  it('crée une commande « nouvelle » avec les montants du serveur', async () => {
    const client = await createUserWithEmailAndPassword(auth, 'awa@exemple.com', 'motdepasse1');
    await setDoc(doc(db, `users/${client.user.uid}`), { nom: 'Awa', role: 'client' });
    const res = await creerCommande({
      commerceId: 'mama', mode: 'emporter', methode: 'especes', telephone: '+32 470 00 00 00',
      // Un prix envoyé par l'app serait ignoré : seul l'identifiant compte.
      lignes: [{ produitId: 'a', quantite: 2, prix: 0.01 }],
    });
    assert.equal(res.data.total, 17.69);
    const c = (await getDoc(doc(db, `commandes/${res.data.commandeId}`))).data();
    assert.equal(c.statut, 'nouvelle');
    assert.equal(c.clientId, client.user.uid);
    assert.equal(c.clientNom, 'Awa');
    assert.equal(c.proId, 'pro1');
    assert.equal(c.sousTotal, 17);
    assert.equal(c.fraisService, 0.69);
    assert.equal(c.commissionPlateforme, 1.19);
    assert.equal(c.paiement.methode, 'especes');
    assert.equal(c.historique.length, 1);
  });

  it('refusée sous le minimum, avec le montant manquant', async () => {
    await createUserWithEmailAndPassword(auth, 'kofi@exemple.com', 'motdepasse1');
    await assert.rejects(
      creerCommande({
        commerceId: 'mama', mode: 'emporter', methode: 'especes', telephone: '0470',
        lignes: [{ produitId: 'a', quantite: 1 }],
      }),
      (e) => e.code === 'functions/failed-precondition'
        && e.message === 'minimum-non-atteint' && e.details.manque === 1.5,
    );
  });

  it('sans connexion ou sans téléphone : refusée', async () => {
    await signOut(auth);
    await assert.rejects(creerCommande({ commerceId: 'mama' }), (e) => e.code === 'functions/unauthenticated');
    await createUserWithEmailAndPassword(auth, 'ama@exemple.com', 'motdepasse1');
    await assert.rejects(
      creerCommande({ commerceId: 'mama', mode: 'emporter', methode: 'especes', lignes: [{ produitId: 'a', quantite: 2 }] }),
      (e) => e.message === 'telephone-requis',
    );
  });
});
