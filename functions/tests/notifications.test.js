import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { jetonsInvalides, notificationMessage } from '../notifications.js';

const conversation = {
  clientId: 'client1', clientNom: 'Awa', proId: 'pro1', commerceNom: 'Chez Mama',
  participants: ['client1', 'pro1'],
};

describe('notification d\'un nouveau message', () => {
  it('le pro est prévenu d\'un message du client, avec le nom du client', () => {
    const n = notificationMessage({
      conversationId: 'c__client1', conversation, message: { auteur: 'client1', texte: 'Bonjour !' }, langue: 'fr',
    });
    assert.equal(n.destinataire, 'pro1');
    assert.deepEqual(n.notification, { title: 'Awa', body: 'Bonjour !' });
    assert.deepEqual(n.data, { conversationId: 'c__client1' });
  });

  it('le client est prévenu avec le nom du commerce ; photo seule traduite', () => {
    const n = notificationMessage({
      conversationId: 'x', conversation, message: { auteur: 'pro1', texte: '' }, langue: 'pt',
    });
    assert.equal(n.destinataire, 'client1');
    assert.deepEqual(n.notification, { title: 'Chez Mama', body: '📷 Foto' });
  });

  it('texte long raccourci, langue inconnue en français', () => {
    const n = notificationMessage({
      conversationId: 'x', conversation, message: { auteur: 'pro1', texte: 'a'.repeat(300) }, langue: 'de',
    });
    assert.equal(n.notification.body.length, 151);
  });

  it('auteur étranger à la conversation : aucune notification', () => {
    assert.equal(notificationMessage({
      conversationId: 'x', conversation, message: { auteur: 'intrus', texte: 'x' }, langue: 'fr',
    }), null);
  });

  it('jetons invalides repérés après l\'envoi', () => {
    const invalides = jetonsInvalides(['a', 'b', 'c'], [
      { success: true },
      { success: false, error: { code: 'messaging/registration-token-not-registered' } },
      { success: false, error: { code: 'messaging/internal-error' } },
    ]);
    assert.deepEqual(invalides, ['b']);
  });
});

describe('notifications des commandes', () => {
  const commande = {
    statut: 'nouvelle', total: 21.89, devise: 'EUR', clientNom: 'Awa', commerceNom: 'Chez Mama',
  };

  it('nouvelle commande pour le pro, montant en euros', async () => {
    const { notificationCommande } = await import('../notifications.js');
    const n = notificationCommande({ commandeId: 'c1', commande, pourPro: true, langue: 'fr' });
    assert.equal(n.notification.title, 'Nouvelle commande');
    assert.match(n.notification.body, /21,89\s€ de Awa/);
    assert.deepEqual(n.data, { commandeId: 'c1' });
  });

  it('étapes pour le client, motif de refus, anglais', async () => {
    const { notificationCommande } = await import('../notifications.js');
    const prete = notificationCommande({ commandeId: 'c1', commande: { ...commande, statut: 'prete' }, pourPro: false, langue: 'fr' });
    assert.deepEqual(prete.notification, { title: 'Commande prête', body: 'Chez Mama' });
    const refus = notificationCommande({
      commandeId: 'c1', commande: { ...commande, statut: 'refusee', motifRefus: 'Fermé' }, pourPro: false, langue: 'en',
    });
    assert.deepEqual(refus.notification, { title: 'Order declined', body: 'Chez Mama : Fermé' });
  });
});
