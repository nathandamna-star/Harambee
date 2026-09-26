abstract final class Routes {
  static const bienvenue = '/bienvenue';
  static const connexionEmail = '/bienvenue/email';
  static const explorer = '/explorer';
  static const favoris = '/favoris';
  static const messages = '/messages';
  static const monEspace = '/mon-espace';
  static const admin = '/admin';

  // Fiche publique d'un commerce (depuis Explorer ou Favoris)
  static String commerceExplorer(String id) => '/explorer/commerce/$id';
  static String commerceFavoris(String id) => '/favoris/commerce/$id';

  // Commandes
  static const mesCommandes = '/mon-espace/commandes';
  static const commandesPro = '/mon-espace/commandes-pro';
  static String commande(String id) => '/mon-espace/commandes/$id';
  static String reglagesCommande(String id) =>
      '/mon-espace/commerce/$id/commande';
  static const tarifs = '/admin/tarifs';

  // Messagerie
  static String conversation(String id) => '/messages/$id';

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
