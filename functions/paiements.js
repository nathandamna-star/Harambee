// Paiement par carte (Stripe Connect, « destination charges ») : logique pure,
// sans appel à Stripe ni à Firebase, pour pouvoir la tester seule.
//
// Le client paie le total ; Stripe verse au commerce le total moins
// l'`application_fee`, qui revient à Harambee et couvre :
//   commission + frais de service + frais de paiement (estimés).
// Les frais de livraison vont entièrement au commerce.

/** Estimation des frais du prestataire, d'après `parametres/tarifs.paiementCarte`. */
export function fraisPaiementMineur(totalMineur, paiementCarte) {
  if (!paiementCarte) return 0;
  const pct = Number(paiementCarte.pct ?? 0);
  const fixe = Math.round(Number(paiementCarte.fixe ?? 0) * 100);
  return Math.round((totalMineur * pct) / 100) + fixe;
}

/** Montant retenu par Harambee sur un paiement par carte. */
export function commissionApplication(calcul, fraisPaiement) {
  return Math.min(
    calcul.commissionMineur + calcul.fraisServiceMineur + fraisPaiement,
    calcul.totalMineur,
  );
}

/**
 * Traduit un événement Stripe (webhook) en mises à jour Firestore.
 * Renvoie une liste d'actions { collection, id, donnees } ; `fraisReels`
 * indique qu'il faut relire les frais exacts du paiement.
 */
export function actionsEvenementStripe(evenement) {
  const o = evenement?.data?.object ?? {};
  switch (evenement?.type) {
    case 'account.updated': {
      const commerceId = o.metadata?.commerceId;
      if (!commerceId) return [];
      return [{
        collection: 'commerces',
        id: commerceId,
        donnees: { paiementCarteActif: o.charges_enabled === true && o.details_submitted === true },
      }];
    }
    case 'payment_intent.succeeded': {
      const commandeId = o.metadata?.commandeId;
      if (!commandeId) return [];
      return [{
        collection: 'commandes',
        id: commandeId,
        donnees: { 'paiement.statut': 'paye', 'paiement.reference': o.id },
        fraisReels: o.latest_charge ?? null,
      }];
    }
    case 'payment_intent.payment_failed': {
      const commandeId = o.metadata?.commandeId;
      if (!commandeId) return [];
      return [{ collection: 'commandes', id: commandeId, donnees: { 'paiement.statut': 'echoue' } }];
    }
    case 'charge.refunded': {
      const commandeId = o.metadata?.commandeId;
      if (!commandeId || o.refunded !== true) return [];
      return [{ collection: 'commandes', id: commandeId, donnees: { 'paiement.statut': 'rembourse' } }];
    }
    default:
      return [];
  }
}

/**
 * Que faire côté Stripe quand une commande par carte change de statut ?
 * 'rembourser' (déjà payée), 'annuler' (paiement pas encore fait) ou null.
 */
export function actionPaiementApresChangement(avant, apres) {
  if (!avant || !apres || avant.statut === apres.statut) return null;
  if (apres.paiement?.methode !== 'carte') return null;
  if (!['annulee', 'refusee'].includes(apres.statut)) return null;
  if (apres.paiement?.statut === 'paye') return 'rembourser';
  if (apres.paiement?.statut === 'en_attente') return 'annuler';
  return null;
}

/**
 * Qui prévenir après un changement de commande ?
 * - commande par carte : le commerçant n'est prévenu qu'une fois le paiement reçu ;
 * - changement de statut : le client (ou le commerçant si le client annule).
 */
export function notificationApresChangement(avant, apres) {
  if (!avant || !apres) return null;
  const vientDEtrePayee = apres.paiement?.methode === 'carte'
    && avant.paiement?.statut !== 'paye' && apres.paiement?.statut === 'paye';
  if (vientDEtrePayee && apres.statut === 'nouvelle') {
    return { uid: apres.proId, pourPro: true };
  }
  if (avant.statut === apres.statut) return null;
  const pourPro = apres.statut === 'annulee';
  return { uid: pourPro ? apres.proId : apres.clientId, pourPro };
}

/** À la création : le commerçant n'est prévenu que des commandes en espèces. */
export function prevenirProALaCreation(commande) {
  return commande?.paiement?.methode !== 'carte';
}
