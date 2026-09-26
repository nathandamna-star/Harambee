// Calcul des montants d'une commande — la seule source de vérité.
// L'app affiche une estimation, mais c'est ce calcul, côté serveur, qui fixe
// les prix : on ne fait jamais confiance aux montants envoyés par l'app.
// Aucun accès à Firebase ici : le module se teste seul.

/** Nombre de décimales de chaque devise (XOF et XAF n'en ont pas). */
const DECIMALES = { EUR: 2, USD: 2, CAD: 2, XOF: 0, XAF: 0, NGN: 2, GHS: 2, CDF: 2 };

export class ErreurCommande extends Error {
  constructor(code, details = {}) {
    super(code);
    this.code = code;
    this.details = details;
  }
}

/** Montant en unités mineures (centimes) → nombre affichable. */
function versMajeur(mineur, devise) {
  return mineur / 10 ** (DECIMALES[devise] ?? 2);
}

function versMineur(montant, devise) {
  return Math.round(Number(montant) * 10 ** (DECIMALES[devise] ?? 2));
}

/** Tarif applicable : pays, sinon continent, sinon défaut. */
export function tarifPour(tarifs, pays, continent) {
  const t = tarifs?.parPays?.[pays] ?? tarifs?.parContinent?.[continent] ?? tarifs?.defaut;
  if (!t) throw new ErreurCommande('tarifs-manquants');
  return t;
}

/** Vrai si le commerce bénéficie encore de la période de lancement. */
export function enPeriodeLancement(lancement, commerceCreeLe, maintenant) {
  if (!lancement?.inscritsAvant || !commerceCreeLe) return false;
  if (commerceCreeLe >= lancement.inscritsAvant) return false;
  const fin = new Date(commerceCreeLe);
  fin.setMonth(fin.getMonth() + (lancement.dureeMois ?? 0));
  return maintenant < fin;
}

function distanceKm(a, b) {
  const rad = (d) => (d * Math.PI) / 180;
  const dLat = rad(b.latitude - a.latitude);
  const dLon = rad(b.longitude - a.longitude);
  const h = Math.sin(dLat / 2) ** 2
    + Math.cos(rad(a.latitude)) * Math.cos(rad(b.latitude)) * Math.sin(dLon / 2) ** 2;
  return 2 * 6371 * Math.asin(Math.sqrt(h));
}

/**
 * Calcule une commande.
 * @param commerce   données du commerce (dont `commande`, `pays`, `continent`, `geo`, `createdAt`)
 * @param produits   { [produitId]: données du produit }
 * @param lignes     [{ produitId, quantite }]
 * @param mode       'livraison' | 'emporter'
 * @param methode    'carte' | 'especes'
 * @param positionLivraison { latitude, longitude } (livraison)
 * @param tarifs     document parametres/tarifs
 * @param maintenant Date
 */
export function calculerCommande({
  commerce, produits, lignes, mode, methode, positionLivraison, tarifs, maintenant,
}) {
  const reglages = commerce.commande;
  if (!reglages?.active) throw new ErreurCommande('commande-inactive');
  if (!(reglages.modes ?? []).includes(mode)) throw new ErreurCommande('mode-indisponible');
  if (methode === 'especes' && !reglages.especesAcceptees) {
    throw new ErreurCommande('especes-refusees');
  }
  if (methode === 'carte' && !commerce.paiementCarteActif) {
    throw new ErreurCommande('carte-indisponible');
  }
  if (!['carte', 'especes'].includes(methode)) throw new ErreurCommande('methode-invalide');
  if (!Array.isArray(lignes) || lignes.length === 0) throw new ErreurCommande('panier-vide');

  const devise = reglages.devise ?? commerce.devise ?? 'EUR';

  // Lignes : prix relus depuis le catalogue, jamais depuis l'app.
  const lignesCalculees = [];
  let sousTotal = 0;
  for (const { produitId, quantite } of lignes) {
    if (!Number.isInteger(quantite) || quantite < 1 || quantite > 99) {
      throw new ErreurCommande('quantite-invalide', { produitId });
    }
    const p = produits[produitId];
    if (!p || p.publie !== true || p.enRupture === true) {
      throw new ErreurCommande('produit-indisponible', { produitId });
    }
    const prix = versMineur(p.prix, devise);
    sousTotal += prix * quantite;
    lignesCalculees.push({
      produitId, nom: p.nom, prixUnitaire: versMajeur(prix, devise), quantite,
    });
  }

  // Minimums de commande.
  const minimum = versMineur(reglages.minimumCommande ?? 0, devise);
  if (sousTotal < minimum) {
    throw new ErreurCommande('minimum-non-atteint', { manque: versMajeur(minimum - sousTotal, devise) });
  }
  let fraisLivraison = 0;
  if (mode === 'livraison') {
    const minimumLivraison = versMineur(reglages.minimumLivraison ?? 0, devise);
    if (sousTotal < minimumLivraison) {
      throw new ErreurCommande('minimum-non-atteint', {
        manque: versMajeur(minimumLivraison - sousTotal, devise),
      });
    }
    if (!positionLivraison) throw new ErreurCommande('adresse-requise');
    if (commerce.geo && reglages.rayonLivraisonKm != null
      && distanceKm(commerce.geo, positionLivraison) > reglages.rayonLivraisonKm) {
      throw new ErreurCommande('hors-zone');
    }
    const gratuite = reglages.livraisonGratuiteDes;
    fraisLivraison = gratuite != null && sousTotal >= versMineur(gratuite, devise)
      ? 0
      : versMineur(reglages.fraisLivraison ?? 0, devise);
  }

  // Frais de service (payés par le client) et commission (payée par le commerce).
  const tarif = tarifPour(tarifs, commerce.pays, commerce.continent);
  let fraisService;
  if (tarif.fraisServicePct != null) {
    fraisService = Math.round((sousTotal * tarif.fraisServicePct) / 100);
    if (tarif.fraisServicePlafond != null) {
      fraisService = Math.min(fraisService, versMineur(tarif.fraisServicePlafond, devise));
    }
  } else {
    fraisService = versMineur(tarif.fraisServiceFixe ?? 0, devise);
  }
  const lancement = enPeriodeLancement(tarifs.lancement, commerce.createdAt, maintenant);
  const commissionPct = lancement ? (tarifs.lancement.commissionPct ?? 0) : (tarif.commissionPct ?? 0);
  // Commission sur le sous-total uniquement : jamais sur la livraison.
  const commission = Math.round((sousTotal * commissionPct) / 100);
  const total = sousTotal + fraisLivraison + fraisService;

  return {
    lignes: lignesCalculees,
    devise,
    sousTotal: versMajeur(sousTotal, devise),
    fraisLivraison: versMajeur(fraisLivraison, devise),
    fraisService: versMajeur(fraisService, devise),
    commissionPlateforme: versMajeur(commission, devise),
    commissionPct,
    periodeLancement: lancement,
    total: versMajeur(total, devise),
    totalMineur: total,
    fraisServiceMineur: fraisService,
    commissionMineur: commission,
  };
}
