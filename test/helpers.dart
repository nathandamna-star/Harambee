import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/app.dart';
import 'package:harambee/core/preferences/preferences.dart';
import 'package:harambee/features/auth/auth_providers.dart';
import 'package:harambee/features/auth/data/connexion_google.dart';
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

/// Environnement de test : Firebase simulé, préférences en mémoire.
class Banc {
  Banc({MockFirebaseAuth? auth, FakeFirebaseFirestore? firestore})
    : auth = auth ?? MockFirebaseAuth(),
      firestore = firestore ?? FakeFirebaseFirestore();

  final MockFirebaseAuth auth;
  final FakeFirebaseFirestore firestore;
  final google = FausseConnexionGoogle();

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
