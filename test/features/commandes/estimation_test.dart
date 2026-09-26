import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/features/commandes/data/panier.dart';
import 'package:harambee/shared/models/commande.dart';
import 'package:harambee/shared/models/commerce.dart';
import 'package:harambee/shared/models/enums.dart';
import 'package:harambee/shared/models/produit.dart';
import 'package:harambee/shared/models/tarifs.dart';

/// Mêmes cas que functions/tests/commandes.test.js : l'estimation affichée
/// doit être identique au calcul du serveur.
void main() {
  const commerce = Commerce(
    id: 'mama',
    nom: 'Chez Mama',
    categorie: Categorie.restaurant,
    proprietaire: 'pro1',
    continent: Continent.europe,
    pays: 'BE',
    commande: ReglagesCommande(
      active: true,
      modes: {ModeCommande.livraison, ModeCommande.emporter},
      minimumCommande: 10,
      minimumLivraison: 20,
      fraisLivraison: 3.5,
      livraisonGratuiteDes: 40,
    ),
  );
  const a = Produit(id: 'a', nom: 'Attiéké', prix: 8.5, devise: Devise.EUR);
  const b = Produit(id: 'b', nom: 'Alloco', prix: 4.2, devise: Devise.EUR);
  final tarifs = Tarifs(
    defaut: const TarifRegion(commissionPct: 6, fraisServiceFixe: 0.49),
    parPays: const {
      'BE': TarifRegion(commissionPct: 7, fraisServiceFixe: 0.69),
    },
  );
  Panier panier(List<(Produit, int)> lignes) {
    var p = const Panier(commerce: commerce);
    for (final (produit, q) in lignes) {
      p = p.avec(produit, q);
    }
    return p;
  }

  test('à emporter : sous-total, frais de service du pays, total', () {
    final e = EstimationPanier.calculer(
      panier([(a, 2), (b, 1)]),
      ModeCommande.emporter,
      tarifs,
    );
    expect(e.sousTotal, 21.2);
    expect(e.fraisService, 0.69);
    expect(e.total, 21.89);
    expect(e.minimumAtteint, isTrue);
  });

  test('livraison : frais, puis offerte à partir du seuil', () {
    final e = EstimationPanier.calculer(
      panier([(a, 3)]),
      ModeCommande.livraison,
      tarifs,
    );
    expect(e.fraisLivraison, 3.5);
    expect(e.total, 29.69);
    final gratuite = EstimationPanier.calculer(
      panier([(a, 5)]),
      ModeCommande.livraison,
      tarifs,
    );
    expect(gratuite.fraisLivraison, 0);
  });

  test('montant manquant pour le minimum (livraison plus exigeante)', () {
    expect(
      EstimationPanier.calculer(
        panier([(b, 1)]),
        ModeCommande.emporter,
        tarifs,
      ).manquePourMinimum,
      5.8,
    );
    expect(
      EstimationPanier.calculer(
        panier([(a, 2)]),
        ModeCommande.livraison,
        tarifs,
      ).manquePourMinimum,
      3,
    );
  });

  test('frais de service en pourcentage plafonné', () {
    const t = TarifRegion(
      commissionPct: 5,
      fraisServicePct: 2,
      fraisServicePlafond: 0.99,
    );
    expect(t.fraisService(17), 0.34);
    expect(t.fraisService(85), 0.99);
  });

  test('le panier limite les quantités et retire à 0', () {
    final p = panier([(a, 150)]);
    expect(p.quantite('a'), 99);
    expect(p.avec(a, 0).estVide, isTrue);
  });
}
