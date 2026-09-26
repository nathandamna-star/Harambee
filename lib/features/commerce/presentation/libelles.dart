import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/enums.dart';

/// Libellés traduits des valeurs du modèle.
extension LibellesModele on AppLocalizations {
  String categorie(Categorie c) => switch (c) {
    Categorie.magasin => categorieMagasin,
    Categorie.restaurant => categorieRestaurant,
    Categorie.logement => categorieLogement,
    Categorie.service => categorieService,
  };

  String statutCommerce(StatutCommerce s) => switch (s) {
    StatutCommerce.enVerification => statutEnVerification,
    StatutCommerce.publie => statutPublie,
    StatutCommerce.suspendu => statutSuspendu,
  };

  /// Jours de la semaine, dans l'ordre, avec leur clé stockée dans `horaires`.
  List<(String, String)> get jours => [
    ('lundi', jourLundi),
    ('mardi', jourMardi),
    ('mercredi', jourMercredi),
    ('jeudi', jourJeudi),
    ('vendredi', jourVendredi),
    ('samedi', jourSamedi),
    ('dimanche', jourDimanche),
  ];
}

/// Prix formaté selon la langue et la devise (ex. « 8,50 € », « 3 500 F CFA »).
String formaterPrix(num prix, Devise devise, String locale) =>
    NumberFormat.simpleCurrency(locale: locale, name: devise.name).format(prix);

/// Lit un prix saisi (« 8,50 » ou « 8.50 »). Null si invalide ou négatif.
num? lirePrix(String saisie) {
  final v = num.tryParse(
    saisie.trim().replaceAll(' ', '').replaceAll(',', '.'),
  );
  return (v == null || v < 0) ? null : v;
}
