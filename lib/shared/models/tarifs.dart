import 'package:cloud_firestore/cloud_firestore.dart';

/// Tarif d'une région : commission prélevée au commerce et frais de service
/// payés par le client (montant fixe, ou pourcentage éventuellement plafonné).
class TarifRegion {
  const TarifRegion({
    required this.commissionPct,
    this.fraisServiceFixe,
    this.fraisServicePct,
    this.fraisServicePlafond,
  });

  final num commissionPct;
  final num? fraisServiceFixe;
  final num? fraisServicePct;
  final num? fraisServicePlafond;

  static TarifRegion? depuis(Object? d) {
    if (d is! Map) return null;
    return TarifRegion(
      commissionPct: d['commissionPct'] as num? ?? 0,
      fraisServiceFixe: d['fraisServiceFixe'] as num?,
      fraisServicePct: d['fraisServicePct'] as num?,
      fraisServicePlafond: d['fraisServicePlafond'] as num?,
    );
  }

  Map<String, dynamic> versFirestore() => {
    'commissionPct': commissionPct,
    'fraisServiceFixe': fraisServiceFixe,
    'fraisServicePct': fraisServicePct,
    'fraisServicePlafond': fraisServicePlafond,
  };

  /// Même calcul que la Cloud Function (functions/commandes.js).
  num fraisService(num sousTotal) {
    if (fraisServicePct != null) {
      final f = (sousTotal * fraisServicePct! / 100 * 100).round() / 100;
      return fraisServicePlafond == null
          ? f
          : (f < fraisServicePlafond! ? f : fraisServicePlafond!);
    }
    return fraisServiceFixe ?? 0;
  }
}

/// Document `parametres/tarifs`, modifiable par l'admin.
class Tarifs {
  const Tarifs({
    this.defaut,
    this.parContinent = const {},
    this.parPays = const {},
    this.lancementCommissionPct = 0,
    this.lancementDureeMois = 6,
    this.lancementInscritsAvant,
    this.paiementCartePct,
    this.paiementCarteFixe,
  });

  final TarifRegion? defaut;
  final Map<String, TarifRegion> parContinent;
  final Map<String, TarifRegion> parPays;
  final num lancementCommissionPct;
  final int lancementDureeMois;
  final DateTime? lancementInscritsAvant;

  /// Frais estimés d'un paiement par carte (pourcentage + montant fixe),
  /// retenus au commerce pour couvrir le prestataire de paiement.
  final num? paiementCartePct;
  final num? paiementCarteFixe;

  TarifRegion? pour(String pays, String continent) =>
      parPays[pays] ?? parContinent[continent] ?? defaut;

  factory Tarifs.depuis(Map<String, dynamic>? d) {
    if (d == null) return const Tarifs();
    Map<String, TarifRegion> table(Object? m) => {
      for (final e in (m as Map? ?? const {}).entries)
        if (TarifRegion.depuis(e.value) != null)
          e.key as String: TarifRegion.depuis(e.value)!,
    };
    final l = d['lancement'] as Map<String, dynamic>? ?? const {};
    return Tarifs(
      defaut: TarifRegion.depuis(d['defaut']),
      parContinent: table(d['parContinent']),
      parPays: table(d['parPays']),
      lancementCommissionPct: l['commissionPct'] as num? ?? 0,
      lancementDureeMois: (l['dureeMois'] as num? ?? 6).toInt(),
      lancementInscritsAvant: (l['inscritsAvant'] as Timestamp?)?.toDate(),
      paiementCartePct: (d['paiementCarte'] as Map?)?['pct'] as num?,
      paiementCarteFixe: (d['paiementCarte'] as Map?)?['fixe'] as num?,
    );
  }

  Map<String, dynamic> versFirestore() => {
    'defaut': defaut?.versFirestore(),
    'parContinent': {
      for (final e in parContinent.entries) e.key: e.value.versFirestore(),
    },
    'parPays': {
      for (final e in parPays.entries) e.key: e.value.versFirestore(),
    },
    'lancement': {
      'commissionPct': lancementCommissionPct,
      'dureeMois': lancementDureeMois,
      'inscritsAvant': lancementInscritsAvant == null
          ? null
          : Timestamp.fromDate(lancementInscritsAvant!),
    },
    'paiementCarte': {'pct': paiementCartePct, 'fixe': paiementCarteFixe},
  };
}
