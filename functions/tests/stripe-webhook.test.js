import assert from 'node:assert/strict';
import { after, beforeEach, describe, it } from 'node:test';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectFirestoreEmulator, doc, getDoc, getFirestore, setDoc } from 'firebase/firestore';
import Stripe from 'stripe';

// Secret factice de functions/.secret.local : le webhook signé ainsi est accepté.
const SECRET = 'whsec_emulateur';
const PROJET = 'demo-harambee';
const URL = `http://127.0.0.1:5001/${PROJET}/europe-west1/stripeWebhook`;
const stripe = new Stripe('sk_test_factice');

const app = initializeApp({ projectId: PROJET, apiKey: 'demo-cle' }, 'webhook');
const db = getFirestore(app);
connectFirestoreEmulator(db, '127.0.0.1', 8080, { mockUserToken: 'owner' });

after(async () => { await deleteApp(app); });

async function envoyer(evenement, secret = SECRET) {
  const corps = JSON.stringify(evenement);
  const signature = stripe.webhooks.generateTestHeaderString({ payload: corps, secret });
  return fetch(URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'stripe-signature': signature },
    body: corps,
  });
}

describe('webhook Stripe (émulateur)', () => {
  beforeEach(async () => {
    await fetch(`http://127.0.0.1:8080/emulator/v1/projects/${PROJET}/databases/(default)/documents`, { method: 'DELETE' });
    await setDoc(doc(db, 'commandes/c1'), {
      statut: 'nouvelle', paiement: { methode: 'carte', statut: 'en_attente', reference: 'pi_1' },
    });
    await setDoc(doc(db, 'commerces/mama'), { nom: 'Chez Mama', paiementCarteActif: false });
  });

  it('paiement réussi : commande payée', async () => {
    const r = await envoyer({
      id: 'evt_1', object: 'event', type: 'payment_intent.succeeded',
      data: { object: { id: 'pi_1', object: 'payment_intent', metadata: { commandeId: 'c1' } } },
    });
    assert.equal(r.status, 200);
    const c = (await getDoc(doc(db, 'commandes/c1'))).data();
    assert.equal(c.paiement.statut, 'paye');
    assert.equal(c.paiement.reference, 'pi_1');
  });

  it('compte Stripe validé : paiement par carte activé pour le commerce', async () => {
    await envoyer({
      id: 'evt_2', object: 'event', type: 'account.updated',
      data: { object: { id: 'acct_1', charges_enabled: true, details_submitted: true, metadata: { commerceId: 'mama' } } },
    });
    assert.equal((await getDoc(doc(db, 'commerces/mama'))).data().paiementCarteActif, true);
  });

  it('signature invalide : refusé, rien ne change', async () => {
    const r = await envoyer({
      id: 'evt_3', object: 'event', type: 'payment_intent.succeeded',
      data: { object: { id: 'pi_1', metadata: { commandeId: 'c1' } } },
    }, 'whsec_pirate');
    assert.equal(r.status, 400);
    assert.equal((await getDoc(doc(db, 'commandes/c1'))).data().paiement.statut, 'en_attente');
  });
});
