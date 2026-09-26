// Construction des notifications push (sans accès à Firebase : testable seul).

const TEXTES = {
  fr: {
    photo: '📷 Photo', nouveau: 'Nouveau message',
    nouvelleCommande: 'Nouvelle commande', de: 'de',
    statuts: {
      acceptee: 'Commande acceptée', en_preparation: 'Commande en préparation',
      prete: 'Commande prête', en_livraison: 'Commande en route', livree: 'Commande livrée',
      retiree: 'Commande retirée', refusee: 'Commande refusée', annulee: 'Commande annulée',
    },
  },
  en: {
    photo: '📷 Photo', nouveau: 'New message',
    nouvelleCommande: 'New order', de: 'from',
    statuts: {
      acceptee: 'Order accepted', en_preparation: 'Order being prepared',
      prete: 'Order ready', en_livraison: 'Order on its way', livree: 'Order delivered',
      retiree: 'Order picked up', refusee: 'Order declined', annulee: 'Order cancelled',
    },
  },
  pt: {
    photo: '📷 Foto', nouveau: 'Nova mensagem',
    nouvelleCommande: 'Novo pedido', de: 'de',
    statuts: {
      acceptee: 'Pedido aceito', en_preparation: 'Pedido em preparo',
      prete: 'Pedido pronto', en_livraison: 'Pedido a caminho', livree: 'Pedido entregue',
      retiree: 'Pedido retirado', refusee: 'Pedido recusado', annulee: 'Pedido cancelado',
    },
  },
};

function montant(valeur, devise, langue) {
  const locale = { fr: 'fr-BE', en: 'en-GB', pt: 'pt-PT' }[langue] ?? 'fr-BE';
  return new Intl.NumberFormat(locale, { style: 'currency', currency: devise }).format(valeur);
}

/** Notification d'une commande : nouvelle (pour le pro) ou changement de statut. */
export function notificationCommande({ commandeId, commande, pourPro, langue }) {
  const t = TEXTES[langue] ?? TEXTES.fr;
  const total = montant(commande.total, commande.devise, langue);
  if (commande.statut === 'nouvelle') {
    return {
      notification: {
        title: t.nouvelleCommande,
        body: `${total} ${t.de} ${commande.clientNom || '—'}`,
      },
      data: { commandeId },
    };
  }
  const titre = t.statuts[commande.statut] ?? commande.statut;
  const corps = commande.statut === 'refusee' && commande.motifRefus
    ? `${commande.commerceNom} : ${commande.motifRefus}`
    : pourPro ? `${commande.clientNom || '—'} · ${total}` : commande.commerceNom;
  return { notification: { title: titre, body: corps }, data: { commandeId } };
}

/**
 * Prépare la notification d'un nouveau message pour son destinataire.
 * Renvoie null si personne n'est à prévenir.
 */
export function notificationMessage({ conversationId, conversation, message, langue }) {
  const participants = conversation?.participants ?? [];
  const destinataire = participants.find((uid) => uid !== message.auteur);
  if (!destinataire || !participants.includes(message.auteur)) return null;

  const t = TEXTES[langue] ?? TEXTES.fr;
  const deClient = message.auteur === conversation.clientId;
  const titre = (deClient ? conversation.clientNom : conversation.commerceNom) || t.nouveau;
  const texte = (message.texte ?? '').trim();
  const corps = texte ? (texte.length > 150 ? `${texte.slice(0, 150)}…` : texte) : t.photo;

  return {
    destinataire,
    notification: { title: titre, body: corps },
    data: { conversationId },
  };
}

/** Jetons à retirer après un envoi (téléphone désinstallé, jeton expiré). */
export function jetonsInvalides(jetons, reponses) {
  const codes = new Set([
    'messaging/registration-token-not-registered',
    'messaging/invalid-registration-token',
    'messaging/invalid-argument',
  ]);
  return jetons.filter((_, i) => !reponses[i]?.success && codes.has(reponses[i]?.error?.code));
}
