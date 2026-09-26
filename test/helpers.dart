import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/app.dart';
import 'package:harambee/core/preferences/preferences.dart';
import 'package:harambee/features/auth/auth_providers.dart';
import 'package:harambee/features/auth/data/connexion_google.dart';
import 'package:harambee/features/commerce/commerce_providers.dart';
import 'package:harambee/features/commerce/data/localisation_service.dart';
import 'package:harambee/features/commerce/data/photos_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FausseConnexionGoogle implements ConnexionGoogle {
  bool connecte = false;

  @override
  Future<String> obtenirIdToken() async {
    connecte = true;
    return 'jeton-google-de-test';
  }

  @override
  Future<void> deconnecter() async => connecte = false;
}

/// Image PNG valide de 1×1 pixel.
final imageTest = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

class FauxSelecteurPhoto implements SelecteurPhoto {
  int appels = 0;

  @override
  Future<Uint8List?> choisir({required bool camera}) async {
    appels++;
    return imageTest;
  }
}

class FausseLocalisation implements LocalisationService {
  @override
  Future<GeoPoint> positionActuelle() async => const GeoPoint(5.35, -4.02);
}

/// Environnement de test : Firebase simulé, préférences en mémoire.
class Banc {
  Banc({MockFirebaseAuth? auth, FakeFirebaseFirestore? firestore})
    : auth = auth ?? MockFirebaseAuth(),
      firestore = firestore ?? FakeFirebaseFirestore();

  final MockFirebaseAuth auth;
  final FakeFirebaseFirestore firestore;
  final google = FausseConnexionGoogle();
  final storage = MockFirebaseStorage();
  final selecteur = FauxSelecteurPhoto();

  Future<void> lancer(
    WidgetTester tester, {
    bool bienvenueVue = true,
    Locale locale = const Locale('fr'),
  }) async {
    tester.platformDispatcher.localesTestValue = [locale];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    SharedPreferences.setMockInitialValues({'bienvenueVue': bienvenueVue});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          firebaseAuthProvider.overrideWithValue(auth),
          firestoreProvider.overrideWithValue(firestore),
          connexionGoogleProvider.overrideWithValue(google),
          firebaseStorageProvider.overrideWithValue(storage),
          selecteurPhotoProvider.overrideWithValue(selecteur),
          localisationServiceProvider.overrideWithValue(FausseLocalisation()),
        ],
        child: const HarambeeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// Utilisateur déjà connecté, avec son profil Firestore.
Future<Banc> bancConnecte({
  String role = 'client',
  Map<String, dynamic> claims = const {},
}) async {
  final user = MockUser(
    uid: 'u1',
    email: 'awa@exemple.com',
    displayName: 'Awa',
    customClaim: claims,
  );
  final banc = Banc(auth: MockFirebaseAuth(signedIn: true, mockUser: user));
  await banc.firestore.collection('users').doc('u1').set({
    'nom': 'Awa',
    'email': 'awa@exemple.com',
    'role': role,
  });
  return banc;
}
