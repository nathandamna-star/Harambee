// ignore_for_file: constant_identifier_names
/// Valeurs fixes du modèle de données (voir CLAUDE.md, section 4).
/// Le nom de chaque valeur est celui stocké dans Firestore.
library;

enum Categorie { magasin, restaurant, logement, service }

enum Continent { europe, afrique, amerique }

enum StatutCommerce {
  enVerification('en_verification'),
  publie('publie'),
  suspendu('suspendu');

  const StatutCommerce(this.valeur);
  final String valeur;

  static StatutCommerce depuis(String? v) => values.firstWhere(
    (s) => s.valeur == v,
    orElse: () => StatutCommerce.enVerification,
  );
}

/// Devises acceptées pour les prix.
enum Devise { EUR, USD, CAD, XOF, XAF, NGN, GHS, CDF }

enum CibleSignalement { commerce, avis, message }

/// Lit une énumération depuis Firestore, avec une valeur de repli.
T enumDepuis<T extends Enum>(List<T> valeurs, String? nom, T defaut) =>
    valeurs.asNameMap()[nom] ?? defaut;
