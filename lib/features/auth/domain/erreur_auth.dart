/// Erreurs de connexion, traduites à l'écran par `messageErreurAuth`.
enum ErreurAuth {
  emailInvalide,
  motDePasseFaible,
  emailDejaUtilise,
  identifiantsIncorrects,
  tropDeTentatives,
  reseau,
  annule,
  inconnue;

  static ErreurAuth depuisCode(String code) => switch (code) {
    'invalid-email' => emailInvalide,
    'weak-password' => motDePasseFaible,
    'email-already-in-use' ||
    'account-exists-with-different-credential' => emailDejaUtilise,
    'wrong-password' ||
    'user-not-found' ||
    'invalid-credential' ||
    'user-disabled' => identifiantsIncorrects,
    'too-many-requests' => tropDeTentatives,
    'network-request-failed' => reseau,
    'canceled' || 'web-context-canceled' => annule,
    _ => inconnue,
  };
}

class ExceptionAuth implements Exception {
  const ExceptionAuth(this.erreur);
  final ErreurAuth erreur;

  @override
  String toString() => 'ExceptionAuth($erreur)';
}
