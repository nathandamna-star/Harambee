import 'package:google_sign_in/google_sign_in.dart';

import '../domain/erreur_auth.dart';

/// Obtient un jeton Google à échanger contre une session Firebase.
/// Isolé derrière une interface pour pouvoir le remplacer dans les tests.
abstract interface class ConnexionGoogle {
  /// Renvoie l'idToken Google, ou lève [ExceptionAuth].
  Future<String> obtenirIdToken();
  Future<void> deconnecter();
}

class ConnexionGoogleNative implements ConnexionGoogle {
  ConnexionGoogleNative({this.clientId, this.serverClientId});

  /// Identifiant « client iOS » (null sur Android).
  final String? clientId;

  /// Identifiant « client Web » du projet Firebase, requis sur Android.
  final String? serverClientId;
  Future<void>? _initialisation;

  Future<void> _initialiser() => _initialisation ??= GoogleSignIn.instance
      .initialize(clientId: clientId, serverClientId: serverClientId);

  @override
  Future<String> obtenirIdToken() async {
    await _initialiser();
    try {
      final compte = await GoogleSignIn.instance.authenticate();
      final idToken = compte.authentication.idToken;
      if (idToken == null) throw const ExceptionAuth(ErreurAuth.inconnue);
      return idToken;
    } on GoogleSignInException catch (e) {
      throw ExceptionAuth(
        e.code == GoogleSignInExceptionCode.canceled
            ? ErreurAuth.annule
            : ErreurAuth.inconnue,
      );
    }
  }

  @override
  Future<void> deconnecter() async {
    await _initialiser();
    await GoogleSignIn.instance.signOut();
  }
}
