import '../../../shared/models/commande.dart';
import '../../../shared/models/enums.dart';

/// Une commande compte dans les revenus quand elle est terminée avec succès
/// (livrée ou retirée) et, si elle est payée par carte, effectivement payée.
bool compteDansRevenus(Commande c) =>
    (c.statut == StatutCommande.livree || c.statut == StatutCommande.retiree) &&
    (c.methodePaiement == MethodePaiement.especes ||
        c.statutPaiement == StatutPaiement.paye);

/// Mois civil (clé de regroupement).
typedef Mois = ({int annee, int mois});

Mois moisDe(DateTime d) => (annee: d.year, mois: d.month);

num _arrondi(num v) => (v * 100).round() / 100;

/// Récapitulatif d'un commerçant pour un mois et une devise.
class RecapMensuel {
  RecapMensuel(this.devise, this.commandes);

  final Devise devise;
  final List<Commande> commandes;

  int get nb => commandes.length;
  num _somme(num Function(Commande) f, [bool Function(Commande)? filtre]) =>
      _arrondi(
        commandes.where(filtre ?? (_) => true).fold<num>(0, (t, c) => t + f(c)),
      );

  /// Total payé par les clients.
  num get ventes => _somme((c) => c.total);
  num get fraisLivraison => _somme((c) => c.fraisLivraison);
  num get fraisService => _somme((c) => c.fraisService);
  num get commission => _somme((c) => c.commissionPlateforme);
  num get fraisPaiement => _somme((c) => c.fraisPaiement);

  /// Ce qui revient au commerçant sur l'ensemble du mois.
  num get net => _somme((c) => c.montantNet);

  static bool _carte(Commande c) => c.methodePaiement == MethodePaiement.carte;
  static bool _especes(Commande c) =>
      c.methodePaiement == MethodePaiement.especes;

  num get ventesCarte => _somme((c) => c.total, _carte);

  /// Versé par Stripe sur le compte du commerçant (déjà net).
  num get verseCarte => _somme((c) => c.montantNet, _carte);
  num get ventesEspeces => _somme((c) => c.total, _especes);

  /// Dû à Harambee sur les commandes en espèces (le commerçant a tout
  /// encaissé) : frais de service payés par les clients + commission.
  num get duEspeces =>
      _somme((c) => c.fraisService + c.commissionPlateforme, _especes);
}

/// Commandes d'un commerçant regroupées par mois et devise.
Map<(Mois, Devise), RecapMensuel> recapsMensuels(List<Commande> commandes) {
  final groupes = <(Mois, Devise), List<Commande>>{};
  for (final c in commandes.where(compteDansRevenus)) {
    if (c.createdAt == null) continue;
    groupes.putIfAbsent((moisDe(c.createdAt!), c.devise), () => []).add(c);
  }
  return {
    for (final e in groupes.entries) e.key: RecapMensuel(e.key.$2, e.value),
  };
}

/// Revenus de Harambee pour un mois, une devise (et éventuellement un pays).
class RevenusMois {
  RevenusMois(this.commandes);

  final List<Commande> commandes;

  num _somme(num Function(Commande) f) =>
      _arrondi(commandes.fold<num>(0, (t, c) => t + f(c)));

  int get nb => commandes.length;
  num get commissions => _somme((c) => c.commissionPlateforme);
  num get fraisService => _somme((c) => c.fraisService);

  /// Frais de paiement retenus aux commerçants (estimés)…
  num get fraisPaiementRetenus => _somme(
    (c) => c.methodePaiement == MethodePaiement.carte ? c.fraisPaiement : 0,
  );

  /// … et frais réellement facturés par Stripe.
  num get fraisPaiementReels => _somme(
    (c) => c.methodePaiement == MethodePaiement.carte
        ? (c.fraisPaiementReel ?? c.fraisPaiement)
        : 0,
  );

  /// Revenu de la plateforme : commissions + frais de service, plus l'écart
  /// entre frais de paiement retenus et frais réels.
  num get total => _arrondi(
    commissions + fraisService + fraisPaiementRetenus - fraisPaiementReels,
  );

  /// Encore à facturer : commandes en espèces (commission + frais de service).
  num get aFacturerEspeces => _somme(
    (c) => c.methodePaiement == MethodePaiement.especes
        ? c.commissionPlateforme + c.fraisService
        : 0,
  );
}

/// Revenus de la plateforme par mois et devise, filtrés par pays si besoin.
Map<(Mois, Devise), RevenusMois> revenusParMois(
  List<Commande> commandes, {
  String? pays,
}) {
  final groupes = <(Mois, Devise), List<Commande>>{};
  for (final c in commandes.where(compteDansRevenus)) {
    if (c.createdAt == null || (pays != null && c.pays != pays)) continue;
    groupes.putIfAbsent((moisDe(c.createdAt!), c.devise), () => []).add(c);
  }
  return {for (final e in groupes.entries) e.key: RevenusMois(e.value)};
}

/// Montant dû par chaque commerce sur ses commandes en espèces d'un mois.
/// Clé : (commerceId, nom du commerce, devise).
Map<(String, String, Devise), num> duParCommerce(
  List<Commande> commandes,
  Mois mois,
) {
  final du = <(String, String, Devise), num>{};
  for (final c in commandes.where(compteDansRevenus)) {
    if (c.methodePaiement != MethodePaiement.especes ||
        c.createdAt == null ||
        moisDe(c.createdAt!) != mois) {
      continue;
    }
    final cle = (c.commerceId, c.commerceNom, c.devise);
    du[cle] = _arrondi(
      (du[cle] ?? 0) + c.commissionPlateforme + c.fraisService,
    );
  }
  return du;
}

/// Export CSV d'un mois pour le commerçant (séparateur « ; » pour Excel en
/// français, montants avec point décimal).
String csvRecap(RecapMensuel recap, List<String> entetes) {
  String cellule(Object? v) {
    final t = '${v ?? ''}';
    return t.contains(RegExp(r'[;"\n]')) ? '"${t.replaceAll('"', '""')}"' : t;
  }

  String date(DateTime? d) => d == null
      ? ''
      : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  final lignes = [
    entetes.map(cellule).join(';'),
    for (final c in recap.commandes)
      [
        date(c.createdAt),
        c.numero,
        c.clientNom,
        c.methodePaiement.name,
        c.total,
        c.fraisLivraison,
        c.fraisService,
        c.commissionPlateforme,
        c.fraisPaiement,
        _arrondi(c.montantNet),
        c.devise.name,
      ].map(cellule).join(';'),
  ];
  return '${lignes.join('\n')}\n';
}
