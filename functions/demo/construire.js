// Construction des données de démonstration (sans accès à Firebase).
// Les commerces de démo portent `demo: true` et un identifiant « demo-… »
// pour pouvoir être supprimés d'un coup avant le lancement.

const JOURS = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];

const ACCENTS = {
  à: 'a', â: 'a', ä: 'a', á: 'a', ã: 'a', ç: 'c', é: 'e', è: 'e', ê: 'e', ë: 'e',
  î: 'i', ï: 'i', í: 'i', ô: 'o', ö: 'o', ó: 'o', õ: 'o', ù: 'u', û: 'u', ü: 'u',
  ú: 'u', ÿ: 'y', ñ: 'n', œ: 'oe', æ: 'ae',
};

/** Même normalisation que l'app (lib/shared/models/recherche.dart). */
export function motsNormalises(texte) {
  return [...texte.toLowerCase()].map((c) => ACCENTS[c] ?? c).join('')
    .split(/[^a-z0-9]+/).filter(Boolean);
}

export function motsClesRecherche(textes) {
  const cles = new Set();
  for (const mot of textes.flatMap(motsNormalises)) {
    for (let n = 2; n <= mot.length && n <= 15; n++) cles.add(mot.slice(0, n));
  }
  return [...cles].sort();
}

const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/** Geohash standard (même résultat que dart_geohash). */
export function geohash(lat, lng, precision = 9) {
  let [latMin, latMax, lngMin, lngMax] = [-90, 90, -180, 180];
  let hash = '';
  let bit = 0;
  let ch = 0;
  let pair = true;
  while (hash.length < precision) {
    if (pair) {
      const m = (lngMin + lngMax) / 2;
      if (lng >= m) { ch = (ch << 1) | 1; lngMin = m; } else { ch <<= 1; lngMax = m; }
    } else {
      const m = (latMin + latMax) / 2;
      if (lat >= m) { ch = (ch << 1) | 1; latMin = m; } else { ch <<= 1; latMax = m; }
    }
    pair = !pair;
    if (++bit === 5) { hash += BASE32[ch]; bit = 0; ch = 0; }
  }
  return hash;
}

const AVIS = [
  ['Fatou', 5, 'Accueil chaleureux, on se sent comme à la maison.'],
  ['Jean-Paul', 4, 'Très bien, je recommande.'],
  ['Aïcha', 5, 'Exactement ce que je cherchais à Bruxelles !'],
  ['Marc', 4, 'Bon rapport qualité-prix.'],
];

/**
 * Documents Firestore d'un commerce de démo.
 * @returns {{ id, commerce, produits: [{id, data}], avis: [{id, data}] }}
 */
export function construireCommerce(c, index, maintenant) {
  const id = `demo-${c.slug}`;
  const horaires = Object.fromEntries(
    JOURS.map((j) => [j, c.fermeLe.includes(j) ? [] : [c.horaires]]),
  );
  const commerce = {
    demo: true,
    nom: c.nom,
    motsCles: motsClesRecherche([c.nom, c.ville]),
    categorie: c.categorie,
    description: c.description,
    photos: [],
    adresse: c.adresse,
    ville: c.ville,
    pays: 'BE',
    continent: 'europe',
    devise: 'EUR',
    geohash: geohash(c.lat, c.lng),
    horaires,
    telephone: c.telephone,
    labelAfricain: c.africain,
    labelChretien: c.chretien,
    charteSigneeLe: c.chretien ? maintenant : null,
    statut: 'publie',
    proprietaire: 'demo-proprietaire',
    noteMoyenne: 0,
    nbAvis: 0,
    commande: {
      active: c.commande,
      modes: ['emporter', 'livraison'],
      minimumCommande: 10,
      minimumLivraison: 20,
      fraisLivraison: 3.5,
      livraisonGratuiteDes: 40,
      rayonLivraisonKm: 5,
      delaiPreparationMin: 30,
      especesAcceptees: true,
      devise: 'EUR',
    },
    createdAt: maintenant,
    updatedAt: maintenant,
  };
  const produits = c.produits.map(([nom, prix], i) => ({
    id: `p${i + 1}`,
    data: {
      nom, description: '', photoUrl: null, prix, devise: 'EUR',
      publie: true, enRupture: false, ordre: i, createdAt: maintenant, updatedAt: maintenant,
    },
  }));
  // 2 à 4 avis par commerce, variés selon l'index.
  const avis = AVIS.slice(0, 2 + (index % 3)).map(([auteurNom, note, texte], i) => ({
    id: `demo-avis-${i + 1}`,
    data: { auteur: `demo-avis-${i + 1}`, auteurNom, note, texte, createdAt: maintenant },
  }));
  return { id, commerce, produits, avis, lat: c.lat, lng: c.lng };
}
