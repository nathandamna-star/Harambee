import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { calculerCommande, enPeriodeLancement } from '../commandes.js';

const reglages = {
  active: true, modes: ['livraison', 'emporter'], minimumCommande: 10, minimumLivraison: 20,
  fraisLivraison: 3.5, livraisonGratuiteDes: 40, rayonLivraisonKm: 5, delaiPreparationMin: 30,
  especesAcceptees: true, devise: 'EUR',
};
const bruxelles = { latitude: 50.8466, longitude: 4.3528 };
const commerce = {
  pays: 'BE', continent: 'europe', geo: bruxelles, commande: reglages,
  paiementCarteActif: false, createdAt: new Date('2026-01-10'),
};
const produits = {
  a: { nom: 'Attiéké', prix: 8.5, publie: true },
  b: { nom: 'Alloco', prix: 4.2, publie: true },
  cache: { nom: 'Caché', prix: 1, publie: false },
  rupture: { nom: 'Épuisé', prix: 1, publie: true, enRupture: true },
};
const tarifs = {
  defaut: { commissionPct: 6, fraisServiceFixe: 0.49 },
  parPays: { BE: { commissionPct: 7, fraisServiceFixe: 0.69 } },
  lancement: { commissionPct: 0, dureeMois: 6, inscritsAvant: new Date('2026-01-01') },
};
const base = {
  commerce, produits, tarifs, mode: 'emporter', methode: 'especes',
  maintenant: new Date('2026-09-28'),
};

function erreur(code) {
  return (e) => e.code === code;
}

describe('calcul d\'une commande', () => {
  it('prix relus du catalogue, frais de service et commission du pays', () => {
    const r = calculerCommande({ ...base, lignes: [{ produitId: 'a', quantite: 2 }, { produitId: 'b', quantite: 1 }] });
    assert.equal(r.sousTotal, 21.2);
    assert.equal(r.fraisLivraison, 0);
    assert.equal(r.fraisService, 0.69);
    assert.equal(r.commissionPlateforme, 1.48); // 7 % de 21,20
    assert.equal(r.total, 21.89);
    assert.equal(r.totalMineur, 2189);
    assert.deepEqual(r.lignes[0], { produitId: 'a', nom: 'Attiéké', prixUnitaire: 8.5, quantite: 2 });
  });

  it('minimum de commande et minimum de livraison, avec le montant manquant', () => {
    assert.throws(
      () => calculerCommande({ ...base, lignes: [{ produitId: 'b', quantite: 1 }] }),
      (e) => e.code === 'minimum-non-atteint' && e.details.manque === 5.8,
    );
    assert.throws(
      () => calculerCommande({
        ...base, mode: 'livraison', positionLivraison: bruxelles, lignes: [{ produitId: 'a', quantite: 2 }],
      }),
      (e) => e.code === 'minimum-non-atteint' && e.details.manque === 3,
    );
  });

  it('livraison : frais, gratuite à partir du seuil, jamais de commission dessus', () => {
    const r = calculerCommande({
      ...base, mode: 'livraison', positionLivraison: bruxelles, lignes: [{ produitId: 'a', quantite: 3 }],
    });
    assert.equal(r.fraisLivraison, 3.5);
    assert.equal(r.commissionPlateforme, 1.79); // 7 % de 25,50 seulement
    assert.equal(r.total, 29.69);
    const gratuite = calculerCommande({
      ...base, mode: 'livraison', positionLivraison: bruxelles, lignes: [{ produitId: 'a', quantite: 5 }],
    });
    assert.equal(gratuite.fraisLivraison, 0);
  });

  it('livraison hors zone ou sans adresse refusée', () => {
    const anvers = { latitude: 51.2194, longitude: 4.4025 };
    const lignes = [{ produitId: 'a', quantite: 3 }];
    assert.throws(() => calculerCommande({ ...base, mode: 'livraison', positionLivraison: anvers, lignes }), erreur('hors-zone'));
    assert.throws(() => calculerCommande({ ...base, mode: 'livraison', lignes }), erreur('adresse-requise'));
  });

  it('produit masqué, en rupture ou inconnu, quantité invalide', () => {
    for (const produitId of ['cache', 'rupture', 'inconnu']) {
      assert.throws(() => calculerCommande({ ...base, lignes: [{ produitId, quantite: 20 }] }), erreur('produit-indisponible'));
    }
    for (const quantite of [0, -1, 1.5, 100]) {
      assert.throws(() => calculerCommande({ ...base, lignes: [{ produitId: 'a', quantite }] }), erreur('quantite-invalide'));
    }
    assert.throws(() => calculerCommande({ ...base, lignes: [] }), erreur('panier-vide'));
  });

  it('réglages du commerce respectés', () => {
    const lignes = [{ produitId: 'a', quantite: 2 }];
    const inactive = { ...commerce, commande: { ...reglages, active: false } };
    assert.throws(() => calculerCommande({ ...base, commerce: inactive, lignes }), erreur('commande-inactive'));
    const sansEmporter = { ...commerce, commande: { ...reglages, modes: ['livraison'] } };
    assert.throws(() => calculerCommande({ ...base, commerce: sansEmporter, lignes }), erreur('mode-indisponible'));
    const sansEspeces = { ...commerce, commande: { ...reglages, especesAcceptees: false } };
    assert.throws(() => calculerCommande({ ...base, commerce: sansEspeces, lignes }), erreur('especes-refusees'));
    assert.throws(() => calculerCommande({ ...base, methode: 'carte', lignes }), erreur('carte-indisponible'));
  });

  it('frais de service en pourcentage plafonné ; tarif du continent ; tarifs absents', () => {
    const t = { defaut: { commissionPct: 5, fraisServicePct: 2, fraisServicePlafond: 0.99 } };
    const petit = calculerCommande({ ...base, tarifs: t, lignes: [{ produitId: 'a', quantite: 2 }] });
    assert.equal(petit.fraisService, 0.34);
    const gros = calculerCommande({ ...base, tarifs: t, lignes: [{ produitId: 'a', quantite: 10 }] });
    assert.equal(gros.fraisService, 0.99);
    const continent = calculerCommande({
      ...base, tarifs: { parContinent: { europe: { commissionPct: 5, fraisServiceFixe: 0.59 } } },
      lignes: [{ produitId: 'a', quantite: 2 }],
    });
    assert.equal(continent.fraisService, 0.59);
    assert.throws(() => calculerCommande({ ...base, tarifs: {}, lignes: [{ produitId: 'a', quantite: 2 }] }), erreur('tarifs-manquants'));
  });

  it('francs CFA : pas de centimes', () => {
    const cfa = {
      ...commerce, pays: 'CI', continent: 'afrique',
      commande: { ...reglages, devise: 'XOF', minimumCommande: 1000, minimumLivraison: 0 },
    };
    const r = calculerCommande({
      ...base, commerce: cfa,
      produits: { x: { nom: 'Garba', prix: 1500, publie: true } },
      tarifs: { defaut: { commissionPct: 5, fraisServiceFixe: 150 } },
      lignes: [{ produitId: 'x', quantite: 3 }],
    });
    assert.equal(r.sousTotal, 4500);
    assert.equal(r.commissionPlateforme, 225);
    assert.equal(r.total, 4650);
    assert.equal(r.totalMineur, 4650);
  });
});

describe('période de lancement', () => {
  const lancement = { commissionPct: 0, dureeMois: 6, inscritsAvant: new Date('2026-06-01') };

  it('commission à 0 % pendant 6 mois pour les inscrits avant la date', () => {
    const inscrit = new Date('2026-05-10');
    assert.equal(enPeriodeLancement(lancement, inscrit, new Date('2026-09-28')), true);
    assert.equal(enPeriodeLancement(lancement, inscrit, new Date('2026-11-11')), false);
    assert.equal(enPeriodeLancement(lancement, new Date('2026-06-02'), new Date('2026-07-01')), false);
  });

  it('appliquée au calcul', () => {
    const r = calculerCommande({
      ...base,
      commerce: { ...commerce, createdAt: new Date('2026-05-10') },
      tarifs: { ...tarifs, lancement },
      lignes: [{ produitId: 'a', quantite: 2 }],
    });
    assert.equal(r.commissionPlateforme, 0);
    assert.equal(r.periodeLancement, true);
  });
});
