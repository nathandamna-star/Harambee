import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers.dart';

Future<void> ouvrirMonEspace(WidgetTester tester) async {
  await tester.tap(find.text('Mon espace'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('un client passe en compte pro', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await ouvrirMonEspace(tester);
    await toucher(tester, find.text('Vous avez un commerce ?'));
    expect(find.text('Présentez votre commerce'), findsOneWidget);
    final profil = await banc.firestore.doc('users/u1').get();
    expect(profil.data()!['role'], 'pro');
  });

  testWidgets('inscription pro complète en 3 étapes', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.lancer(tester);
    await ouvrirMonEspace(tester);
    await toucher(tester, find.text('Créer la fiche de mon commerce'));
    expect(find.text('Étape 1 sur 3'), findsOneWidget);

    // Étape 1 : champs obligatoires signalés.
    await toucher(tester, find.text('Suivant'));
    expect(find.text('Ce champ est obligatoire.'), findsWidgets);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom du commerce'),
      'Maquis Chez Awa',
    );
    await toucher(tester, find.text('Restaurant'));
    await toucher(
      tester,
      find.widgetWithText(DropdownButtonFormField<String>, 'Pays'),
    );
    await toucher(tester, find.text('Côte d\'Ivoire').last);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Ville'),
      'Abidjan',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse'),
      'Rue des Jardins, Cocody',
    );
    await toucher(tester, find.text('Enregistrer la position du commerce'));
    expect(find.text('Position enregistrée'), findsOneWidget);
    await toucher(tester, find.text('Suivant'));

    // Étape 2 : le label chrétien exige la charte.
    expect(find.text('Étape 2 sur 3'), findsOneWidget);
    await toucher(tester, find.text('Africain'));
    await toucher(tester, find.text('Chrétien'));
    await toucher(tester, find.text('Suivant'));
    expect(
      find.text(
        'Pour demander le label « Chrétien », acceptez d\'abord la charte.',
      ),
      findsOneWidget,
    );
    await toucher(tester, find.text('Lire et accepter la charte'));
    await toucher(tester, find.text('J\'ai lu et j\'accepte la charte'));
    await toucher(tester, find.text('Valider'));
    expect(find.text('Charte acceptée'), findsOneWidget);
    await toucher(tester, find.text('Suivant'));

    // Étape 3 : une photo depuis la galerie, puis envoi.
    expect(find.text('Étape 3 sur 3'), findsOneWidget);
    await toucher(tester, find.bySemanticsLabel('Ajouter une photo'));
    await toucher(tester, find.text('Choisir dans la galerie'));
    expect(banc.selecteur.appels, 1);
    await toucher(tester, find.text('Envoyer pour vérification'));

    final docs = (await banc.firestore.collection('commerces').get()).docs;
    expect(docs, hasLength(1));
    final d = docs.single.data();
    expect(d['nom'], 'Maquis Chez Awa');
    expect(d['statut'], 'en_verification');
    expect(d['proprietaire'], 'u1');
    expect(d['pays'], 'CI');
    expect(d['continent'], 'afrique');
    expect(d['devise'], 'XOF');
    expect(d['labelAfricain'], isTrue);
    expect(d['labelChretien'], isTrue);
    expect(d['charteSigneeLe'], isNotNull);
    expect(d['geohash'], isNotNull);
    expect(d['photos'], hasLength(1));

    // Retour à Mon espace avec le statut de la fiche.
    expect(find.text('Maquis Chez Awa'), findsOneWidget);
    expect(find.text('En vérification'), findsOneWidget);
  });

  testWidgets('catalogue : ajouter, afficher le prix, masquer', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore.doc('commerces/c1').set({
      'nom': 'Chez Mama',
      'categorie': 'magasin',
      'proprietaire': 'u1',
      'continent': 'europe',
      'ville': 'Lyon',
      'statut': 'publie',
      'devise': 'EUR',
    });
    await banc.lancer(tester);
    await ouvrirMonEspace(tester);
    expect(find.text('Publié'), findsOneWidget);

    await toucher(tester, find.text('Catalogue'));
    expect(find.text('Votre catalogue est vide'), findsOneWidget);

    await toucher(tester, find.text('Ajouter un produit'));
    await toucher(tester, find.text('Enregistrer'));
    expect(find.text('Ce champ est obligatoire.'), findsOneWidget);
    expect(find.text('Indiquez un prix valide (ex. 8,50).'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom du produit'),
      'Attiéké',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Prix'), '8,50');
    await toucher(tester, find.text('Enregistrer'));

    expect(find.text('Attiéké'), findsOneWidget);
    expect(find.textContaining('8,50'), findsOneWidget);

    await toucher(tester, find.byTooltip('Actions'));
    await toucher(tester, find.text('Masquer'));
    expect(find.text('Masqué'), findsOneWidget);

    final produits = await banc.firestore
        .collection('commerces/c1/produits')
        .get();
    expect(produits.docs.single.data()['publie'], isFalse);
    expect(produits.docs.single.data()['prix'], 8.5);
  });

  testWidgets('un client ne peut pas ouvrir l\'espace pro', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await ouvrirMonEspace(tester);
    expect(find.text('Créer la fiche de mon commerce'), findsNothing);
    expect(find.text('Catalogue'), findsNothing);
  });
}
