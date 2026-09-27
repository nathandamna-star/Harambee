import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'dart:async';
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
import 'package:harambee/features/commandes/commandes_providers.dart';
import 'package:harambee/features/commandes/data/commandes_repository.dart';
import 'package:harambee/features/commandes/data/paiement_service.dart';
import 'package:harambee/shared/models/commande.dart';
import 'package:harambee/features/commerce/commerce_providers.dart';
import 'package:harambee/features/commerce/data/localisation_service.dart';
import 'package:harambee/features/commerce/data/photos_service.dart';
import 'package:harambee/features/explorer/explorer_providers.dart';
import 'package:harambee/features/explorer/presentation/carte_resultats.dart';
import 'package:harambee/features/notifications/notifications_providers.dart';
import 'package:harambee/features/profil/compte_service.dart';
import 'package:harambee/features/profil/profil_screen.dart';
import 'package:harambee/core/partage/partage.dart';
import 'package:harambee/features/notifications/notifications_service.dart';
import 'package:harambee/shared/models/commerce.dart';
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

/// Position simulée : Abidjan (Plateau), ou erreur si [erreur] est définie.
class FausseLocalisation implements LocalisationService {
  ErreurLocalisation? erreur;

  @override
  Future<GeoPoint> positionActuelle() async {
    if (erreur != null) throw ExceptionLocalisation(erreur!);
    return const GeoPoint(5.32, -4.02);
  }
}

/// Remplace la carte Google (vue native indisponible en test) par une liste
/// de repères cliquables.
Widget fausseCarte({
  required List<ResultatExplorer> resultats,
  required RechercheProche? proche,
  required void Function(Commerce) onOuvrir,
}) => ListView(
  children: [
    for (final r in resultats)
      TextButton(
        onPressed: () => onOuvrir(r.commerce),
        child: Text('Repère ${r.commerce.nom}'),
      ),
  ],
);

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

  @override
  Future<int> chargerDemo() async {
    appels.add('chargerDemo');
    return 10;
  }

  @override
  Future<int> supprimerDemo() async {
    appels.add('supprimerDemo');
    return 10;
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
  Future<bool> ouvrir(Uri url) async {
    appels.add('ouvrir:$url');
    return true;
  }

  @override
  Future<bool> itineraire({GeoPoint? geo, required String adresse}) async {
    appels.add('itineraire:${geo?.latitude},${geo?.longitude}');
    return true;
  }
}

class FaussesNotifications implements NotificationsService {
  final actives = <String>[];
  final desactivees = <String>[];
  final touchees = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<void> activer(String uid) async => actives.add(uid);

  @override
  Future<void> desactiver(String uid) async => desactivees.add(uid);

  @override
  Stream<Map<String, dynamic>> get notificationsTouchees => touchees.stream;
}

/// Remplace la Cloud Function `creerCommande` : enregistre la demande et
/// écrit une commande simple dans la base simulée.
class FaussesFonctionsCommande implements FonctionsCommande {
  FaussesFonctionsCommande(this.firestore);

  final FakeFirebaseFirestore firestore;
  final demandes = <DemandeCommande>[];
  ErreurCommande? erreur;

  /// Secret renvoyé pour un paiement par carte.
  String? secret;
  final liensDemandes = <String>[];

  @override
  Future<String> secretPaiement(String commandeId) async =>
      'secret-$commandeId';

  @override
  Future<Uri> lienPaiementCarte(String commerceId) async {
    liensDemandes.add(commerceId);
    return Uri.parse('https://connect.stripe.com/setup/e/$commerceId');
  }

  @override
  Future<CommandeCreee> creer(DemandeCommande demande) async {
    demandes.add(demande);
    if (erreur != null) throw erreur!;
    final ref = firestore.collection('commandes').doc('cmd123456');
    await ref.set({
      'commerceId': demande.commerceId,
      'commerceNom': 'Chez Mama',
      'clientId': 'u1',
      'clientNom': 'Awa',
      'proId': 'pro1',
      'lignes': [
        for (final e in demande.lignes.entries)
          {
            'produitId': e.key,
            'nom': e.key,
            'prixUnitaire': 8.5,
            'quantite': e.value,
          },
      ],
      'sousTotal': 17,
      'fraisLivraison': 0,
      'fraisService': 0.69,
      'commissionPlateforme': 1.19,
      'fraisPaiement': 0,
      'total': 17.69,
      'devise': 'EUR',
      'mode': demande.mode.name,
      'telephoneClient': demande.telephone,
      'paiement': {
        'methode': demande.methode.name,
        'statut': 'en_attente',
        'reference': 'pi_test',
      },
      'statut': 'nouvelle',
      'historique': [
        {'statut': 'nouvelle', 'date': Timestamp.fromDate(maintenantTest)},
      ],
      'createdAt': Timestamp.fromDate(maintenantTest),
    });
    return (
      id: ref.id,
      clientSecret: demande.methode == MethodePaiement.carte ? 'secret' : null,
    );
  }
}

/// Suppression de compte simulée.
class FauxCompteService implements CompteService {
  int appels = 0;
  ErreurSuppression? erreur;

  @override
  Future<void> supprimerMonCompte() async {
    appels++;
    if (erreur != null) throw erreur!;
  }
}

/// Partage de fichier simulé.
class FauxPartage implements Partage {
  final fichiers = <String, String>{};
  final textes = <String>[];
  final images = <String, Uint8List>{};

  @override
  Future<void> partagerFichier({
    required String nom,
    required String contenu,
    required String typeMime,
  }) async => fichiers[nom] = contenu;

  @override
  Future<void> partagerTexte(
    String texte, {
    String? sujet,
    Rect? origine,
  }) async => textes.add(texte);

  @override
  Future<void> partagerImage(
    Uint8List png, {
    required String nom,
    String? texte,
    Rect? origine,
  }) async => images[nom] = png;
}

/// Formulaire de paiement simulé.
class FauxPaiement implements PaiementService {
  ResultatPaiement resultat = ResultatPaiement.reussi;
  final secrets = <String>[];

  @override
  bool get disponible => true;

  @override
  Future<ResultatPaiement> payer(String clientSecret) async {
    secrets.add(clientSecret);
    return resultat;
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
  final localisation = FausseLocalisation();
  final notifications = FaussesNotifications();
  late final fonctionsCommande = FaussesFonctionsCommande(firestore);
  final paiement = FauxPaiement();
  final partage = FauxPartage();
  final compte = FauxCompteService();

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
          localisationServiceProvider.overrideWithValue(localisation),
          constructeurCarteProvider.overrideWithValue(fausseCarte),
          notificationsServiceProvider.overrideWithValue(notifications),
          fonctionsCommandeProvider.overrideWithValue(fonctionsCommande),
          paiementServiceProvider.overrideWithValue(paiement),
          partageProvider.overrideWithValue(partage),
          compteServiceProvider.overrideWithValue(compte),
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
