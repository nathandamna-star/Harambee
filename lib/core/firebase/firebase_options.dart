// Configuration du projet Firebase « harambee-75bab ».
// Ces valeurs identifient le projet ; elles ne sont pas secrètes.
// La sécurité repose sur les règles Firestore et Storage.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => switch (defaultTargetPlatform) {
    TargetPlatform.android => android,
    TargetPlatform.iOS => ios,
    _ => throw UnsupportedError(
      'Firebase n\'est pas encore configuré pour $defaultTargetPlatform.',
    ),
  };

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyAaQ7SjHVuWFKYaK2Tt58crd2KlVfevUEA',
    appId: '1:456682666828:android:cd9887f4c6fce5ee66ede9',
    messagingSenderId: '456682666828',
    projectId: 'harambee-75bab',
    storageBucket: 'harambee-75bab.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyAaQ7SjHVuWFKYaK2Tt58crd2KlVfevUEA',
    appId: '1:456682666828:ios:224601586e09ad7266ede9',
    messagingSenderId: '456682666828',
    projectId: 'harambee-75bab',
    storageBucket: 'harambee-75bab.firebasestorage.app',
    iosBundleId: 'com.harambee.harambee',
  );
}

/// Identifiant « client Web » OAuth (client_type 3), requis pour Google sur Android.
/// À compléter depuis google-services.json une fois la connexion Google activée.
const String? googleServerClientId = null;
