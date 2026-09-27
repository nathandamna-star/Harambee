import 'package:cloud_functions/cloud_functions.dart';

class ErreurSuppression implements Exception {
  const ErreurSuppression(this.code);

  /// « commandes-en-cours », « reseau » ou « inconnue ».
  final String code;
}

/// Suppression définitive du compte, faite par le serveur (Cloud Function
/// `supprimerMonCompte`), qui efface aussi les données associées.
abstract interface class CompteService {
  Future<void> supprimerMonCompte();
}

class CompteServiceFirebase implements CompteService {
  CompteServiceFirebase(this.fonctions);

  final FirebaseFunctions fonctions;

  @override
  Future<void> supprimerMonCompte() async {
    try {
      await fonctions.httpsCallable('supprimerMonCompte').call<Object?>();
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      final code = details is Map ? details['code'] as String? : null;
      throw ErreurSuppression(
        code ??
            (e.code == 'unavailable' || e.code == 'deadline-exceeded'
                ? 'reseau'
                : 'inconnue'),
      );
    }
  }
}
