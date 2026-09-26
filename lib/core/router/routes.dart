abstract final class Routes {
  static const bienvenue = '/bienvenue';
  static const connexionEmail = '/bienvenue/email';
  static const explorer = '/explorer';
  static const favoris = '/favoris';
  static const messages = '/messages';
  static const monEspace = '/mon-espace';
  static const admin = '/admin';

  // Administration
  static String adminCommerce(String id) => '/admin/commerce/$id';
  static const administrateurs = '/admin/administrateurs';

  // Espace pro
  static const nouveauCommerce = '/mon-espace/commerce/nouveau';
  static String modifierCommerce(String id) => '/mon-espace/commerce/$id';
  static String catalogue(String id) => '/mon-espace/commerce/$id/catalogue';
  static String nouveauProduit(String id) =>
      '/mon-espace/commerce/$id/catalogue/nouveau';
  static String modifierProduit(String id, String produitId) =>
      '/mon-espace/commerce/$id/catalogue/$produitId';
}
