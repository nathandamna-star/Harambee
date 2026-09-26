// Construction des notifications push (sans accès à Firebase : testable seul).

const TEXTES = {
  fr: { photo: '📷 Photo', nouveau: 'Nouveau message' },
  en: { photo: '📷 Photo', nouveau: 'New message' },
  pt: { photo: '📷 Foto', nouveau: 'Nova mensagem' },
};

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
