/// Rôle d'un utilisateur.
///
/// `client` et `pro` sont enregistrés dans `users/{uid}.role`.
/// `admin` vient uniquement d'un *custom claim* Firebase, jamais de l'app.
enum Role {
  client,
  pro,
  admin;

  /// Lit `users/{uid}.role`. Ne renvoie jamais [admin] : une valeur
  /// « admin » écrite dans le profil ne donne aucun droit.
  static Role depuisTexte(String? valeur) =>
      valeur == 'pro' ? Role.pro : Role.client;
}
