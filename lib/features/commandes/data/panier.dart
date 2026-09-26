import '../../../shared/models/commande.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/produit.dart';
import '../../../shared/models/tarifs.dart';

/// Panier d'un client pour un commerce.
class Panier {
  const Panier({required this.commerce, this.lignes = const {}});

  final Commerce commerce;

  /// produitId → (produit, quantité)
  final Map<String, (Produit, int)> lignes;

  int get nbArticles => lignes.values.fold(0, (n, l) => n + l.$2);
  bool get estVide => lignes.isEmpty;

  num get sousTotal =>
      _arrondi(lignes.values.fold<num>(0, (t, l) => t + l.$1.prix * l.$2));

  int quantite(String produitId) => lignes[produitId]?.$2 ?? 0;

  Panier avec(Produit produit, int quantite) {
    final copie = {...lignes};
    if (quantite <= 0) {
      copie.remove(produit.id);
    } else {
      copie[produit.id] = (produit, quantite.clamp(1, 99));
    }
    return Panier(commerce: commerce, lignes: copie);
  }
}

/// Estimation affichée dans le panier. Le montant définitif est recalculé par
/// le serveur au moment de la commande (functions/commandes.js).
class EstimationPanier {
  const EstimationPanier({
    required this.sousTotal,
    required this.fraisLivraison,
    required this.fraisService,
    required this.total,
    required this.manquePourMinimum,
  });

  final num sousTotal;
  final num fraisLivraison;
  final num fraisService;
  final num total;

  /// Montant manquant pour atteindre le minimum (0 si atteint).
  final num manquePourMinimum;

  bool get minimumAtteint => manquePourMinimum <= 0;

  factory EstimationPanier.calculer(
    Panier panier,
    ModeCommande mode,
    Tarifs tarifs,
  ) {
    final r = panier.commerce.commande ?? const ReglagesCommande();
    final sousTotal = panier.sousTotal;
    var minimum = r.minimumCommande;
    num fraisLivraison = 0;
    if (mode == ModeCommande.livraison) {
      if (r.minimumLivraison > minimum) minimum = r.minimumLivraison;
      final gratuite = r.livraisonGratuiteDes;
      fraisLivraison = gratuite != null && sousTotal >= gratuite
          ? 0
          : r.fraisLivraison;
    }
    final tarif = tarifs.pour(
      panier.commerce.pays,
      panier.commerce.continent.name,
    );
    final fraisService = tarif?.fraisService(sousTotal) ?? 0;
    final manque = minimum - sousTotal;
    return EstimationPanier(
      sousTotal: sousTotal,
      fraisLivraison: fraisLivraison,
      fraisService: fraisService,
      total: _arrondi(sousTotal + fraisLivraison + fraisService),
      manquePourMinimum: manque > 0 ? _arrondi(manque) : 0,
    );
  }
}

num _arrondi(num v) => (v * 100).round() / 100;
