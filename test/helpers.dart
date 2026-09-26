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
import 'package:harambee/features/admin/admin_providers.dart';
import 'package:harambee/features/admin/data/fonctions_admin.dart';
import 'package:harambee/features/auth/auth_providers.dart';
import 'package:harambee/features/auth/data/connexion_google.dart';
import 'package:harambee/features/commerce/commerce_providers.dart';
import 'package:harambee/features/commerce/data/localisation_service.dart';
import 'package:harambee/features/commerce/data/photos_service.dart';
import 'package:harambee/features/explorer/explorer_providers.dart';
import 'package:harambee/shared/services/lanceur.dart';
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

class FaussesFonctionsAdmin implements FonctionsAdmin {
  final appels = <String>[];
  ErreurAdmin? erreur;

  @override
  Future<void> revendiquerAdminInitial() async {
    appels.add('revendiquer');
    if (erreur != null) throw ExceptionAdmin(erreur!);
  }

  @override
  Future<void> definirAdmin(String email, {required bool admin}) async {
    appels.add('definir:$email:$admin');
    if (erreur != null) throw ExceptionAdmin(erreur!);
  }
}

class FauxLanceur implements Lanceur {
  final appels = <String>[];

  @override
  Future<bool> appeler(String telephone) async {
    appels.add('tel:$telephone');
    return true;
  }

  @override
  Future<bool> itineraire({GeoPoint? geo, required String adresse}) async {
    appels.add('itineraire:${geo?.latitude},${geo?.longitude}');
    return true;
  }
}

/// Lundi 28 septembre 2026, 10 h.
final maintenantTest = DateTime(2026, 9, 28, 10);

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
  final fonctionsAdmin = FaussesFonctionsAdmin();
  final lanceur = FauxLanceur();

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
          fonctionsAdminProvider.overrideWithValue(fonctionsAdmin),
          lanceurProvider.overrideWithValue(lanceur),
          horlogeProvider.overrideWithValue(() => maintenantTest),
        ],
        child: const HarambeeApp(),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// Écran de téléphone (432 × 960) plutôt que la petite surface par défaut.
/// [grand] : écran très haut, pour les pages longues.
void ecranTelephone(WidgetTester tester, {bool grand = false}) {
  tester.view.physicalSize = Size(1080, grand ? 4800 : 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
}

/// Fait défiler jusqu'à la cible puis la touche.
Future<void> toucher(WidgetTester tester, Finder cible) async {
  await tester.ensureVisible(cible);
  await tester.pumpAndSettle();
  await tester.tap(cible);
  await tester.pumpAndSettle();
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
