import 'package:cloud_functions/cloud_functions.dart';

enum ErreurAdmin {
  nonAutorise,
  compteIntrouvable,
  dejaDesigne,
  soiMeme,
  reseau,
  inconnue,
}

class ExceptionAdmin implements Exception {
  const ExceptionAdmin(this.erreur);
  final ErreurAdmin erreur;
}

/// Appels aux fonctions serveur qui gèrent le rôle administrateur
/// (voir functions/index.js). L'app ne peut jamais s'attribuer ce rôle seule.
abstract interface class FonctionsAdmin {
  /// Premier administrateur : le compte dont l'e-mail a été configuré.
  Future<void> revendiquerAdminInitial();

  /// Nomme ([admin] = true) ou retire un administrateur.
  Future<void> definirAdmin(String email, {required bool admin});
}

class FonctionsAdminFirebase implements FonctionsAdmin {
  FonctionsAdminFirebase(this.fonctions);

  final FirebaseFunctions fonctions;

  @override
  Future<void> revendiquerAdminInitial() =>
      _appeler('revendiquerAdminInitial', null);

  @override
  Future<void> definirAdmin(String email, {required bool admin}) =>
      _appeler('definirAdmin', {'email': email.trim(), 'admin': admin});

  Future<void> _appeler(String nom, Object? donnees) async {
    try {
      await fonctions.httpsCallable(nom).call<Object?>(donnees);
    } on FirebaseFunctionsException catch (e) {
      throw ExceptionAdmin(switch (e.code) {
        'permission-denied' || 'unauthenticated' => ErreurAdmin.nonAutorise,
        'not-found' || 'invalid-argument' => ErreurAdmin.compteIntrouvable,
        'failed-precondition' =>
          nom == 'definirAdmin' ? ErreurAdmin.soiMeme : ErreurAdmin.dejaDesigne,
        'unavailable' || 'deadline-exceeded' => ErreurAdmin.reseau,
        _ => ErreurAdmin.inconnue,
      });
    }
  }
}
