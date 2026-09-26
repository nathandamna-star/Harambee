// PROVISOIRE : sera remplacé par la configuration du projet Firebase
// (fichiers google-services.json et GoogleService-Info.plist).
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase n\'est pas encore configuré pour $defaultTargetPlatform.',
  );
}

/// Identifiant « client Web » OAuth (client_type 3), requis pour Google sur Android.
const String? googleServerClientId = null;
