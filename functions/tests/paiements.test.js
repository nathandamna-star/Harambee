import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import {
  actionPaiementApresChangement, actionsEvenementStripe, commissionApplication,
  fraisPaiementMineur, notificationApresChangement, prevenirProALaCreation,
} from '../paiements.js';

describe('montants retenus sur un paiement par carte', () => {
  it('frais estimés : 1,5 % + 0,25 €', () => {
    assert.equal(fraisPaiementMineur(1769, { pct: 1.5, fixe: 0.25 }), 52);
    assert.equal(fraisPaiementMineur(1769, null), 0);
  });

  it('commission + frais de service + frais de paiement, jamais plus que le total', () => {
    const calcul = { commissionMineur: 119, fraisServiceMineur: 69, totalMineur: 1769 };
    assert.equal(commissionApplication(calcul, 52), 240);
    assert.equal(commissionApplication({ ...calcul, totalMineur: 100 }, 52), 100);
  });
});

describe('événements Stripe', () => {
  it('compte du commerce activé', () => {
    const a = actionsEvenementStripe({
      type: 'account.updated',
      data: { object: { metadata: { commerceId: 'mama' }, charges_enabled: true, details_submitted: true } },
    });
    assert.deepEqual(a, [{ collection: 'commerces', id: 'mama', donnees: { paiementCarteActif: true } }]);
  });

  it('paiement réussi : commande payée, frais réels à relire', () => {
    const [a] = actionsEvenementStripe({
      type: 'payment_intent.succeeded',
      data: { object: { id: 'pi_1', latest_charge: 'ch_1', metadata: { commandeId: 'c1' } } },
    });
    assert.deepEqual(a.donnees, { 'paiement.statut': 'paye', 'paiement.reference': 'pi_1' });
    assert.equal(a.fraisReels, 'ch_1');
  });

  it('échec, remboursement, événements inconnus ou sans commande', () => {
    assert.equal(actionsEvenementStripe({
      type: 'payment_intent.payment_failed', data: { object: { metadata: { commandeId: 'c1' } } },
    })[0].donnees['paiement.statut'], 'echoue');
    assert.equal(actionsEvenementStripe({
      type: 'charge.refunded', data: { object: { refunded: true, metadata: { commandeId: 'c1' } } },
    })[0].donnees['paiement.statut'], 'rembourse');
    assert.deepEqual(actionsEvenementStripe({ type: 'charge.refunded', data: { object: { refunded: false, metadata: { commandeId: 'c1' } } } }), []);
    assert.deepEqual(actionsEvenementStripe({ type: 'customer.created', data: { object: {} } }), []);
    assert.deepEqual(actionsEvenementStripe({ type: 'payment_intent.succeeded', data: { object: {} } }), []);
  });
});

describe('annulation ou refus d\'une commande par carte', () => {
  const carte = (statutPaiement, statut) => ({ statut, paiement: { methode: 'carte', statut: statutPaiement } });

  it('payée : remboursement ; pas encore payée : annulation du paiement', () => {
    assert.equal(actionPaiementApresChangement(carte('paye', 'nouvelle'), carte('paye', 'refusee')), 'rembourser');
    assert.equal(actionPaiementApresChangement(carte('en_attente', 'nouvelle'), carte('en_attente', 'annulee')), 'annuler');
  });

  it('rien pour les espèces, les autres statuts ou sans changement', () => {
    const especes = { statut: 'annulee', paiement: { methode: 'especes', statut: 'en_attente' } };
    assert.equal(actionPaiementApresChangement({ statut: 'nouvelle' }, especes), null);
    assert.equal(actionPaiementApresChangement(carte('paye', 'nouvelle'), carte('paye', 'acceptee')), null);
    assert.equal(actionPaiementApresChangement(carte('paye', 'refusee'), carte('rembourse', 'refusee')), null);
  });
});

describe('qui prévenir', () => {
  const base = { proId: 'pro1', clientId: 'client1', statut: 'nouvelle' };

  it('commande par carte : le pro est prévenu au paiement, pas à la création', () => {
    const avant = { ...base, paiement: { methode: 'carte', statut: 'en_attente' } };
    const apres = { ...base, paiement: { methode: 'carte', statut: 'paye' } };
    assert.equal(prevenirProALaCreation(avant), false);
    assert.deepEqual(notificationApresChangement(avant, apres), { uid: 'pro1', pourPro: true });
    assert.equal(prevenirProALaCreation({ paiement: { methode: 'especes' } }), true);
  });

  it('étapes : le client ; annulation : le pro', () => {
    const avant = { ...base, paiement: { methode: 'especes' } };
    assert.deepEqual(notificationApresChangement(avant, { ...avant, statut: 'acceptee' }), { uid: 'client1', pourPro: false });
    assert.deepEqual(notificationApresChangement(avant, { ...avant, statut: 'annulee' }), { uid: 'pro1', pourPro: true });
    assert.equal(notificationApresChangement(avant, { ...avant }), null);
  });
});
