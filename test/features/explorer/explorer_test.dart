import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/shared/models/recherche.dart';

import '../../helpers.dart';

Map<String, dynamic> commerce(
  String nom, {
  String statut = 'publie',
  String ville = 'Lyon',
  String categorie = 'restaurant',
  String continent = 'europe',
  bool chretien = false,
  Map<String, List<String>> horaires = const {},
  double note = 0,
  int nbAvis = 0,
  String proprietaire = 'pro1',
}) => {
  'nom': nom,
  'ville': ville,
  'motsCles': motsClesRecherche([nom, ville]),
  'categorie': categorie,
  'continent': continent,
  'statut': statut,
  'labelAfricain': true,
  'labelChretien': chretien,
  'horaires': horaires,
  'noteMoyenne': note,
  'nbAvis': nbAvis,
  'proprietaire': proprietaire,
  'adresse': '1 rue X',
  'telephone': '+33 4 00 00 00 00',
  'geo': const GeoPoint(45.76, 4.83),
  'photos': <String>[],
};

Future<void> preparer(Banc banc) async {
  final db = banc.firestore;
  await db
      .doc('commerces/mama')
      .set(
        commerce(
          'Chez Mama',
          note: 4.5,
          nbAvis: 12,
          horaires: {
            'lundi': ['09:00-19:00'],
          },
        ),
      );
  await db
      .doc('commerces/grace')
      .set(
        commerce(
          'Boutique Grâce',
          ville: 'Abidjan',
          categorie: 'magasin',
          continent: 'afrique',
          chretien: true,
        ),
      );
  await db
      .doc('commerces/attente')
      .set(commerce('Pas Encore', statut: 'en_verification'));
  await db.doc('commerces/mama/produits/p1').set({
    'nom': 'Attiéké',
    'prix': 8.5,
    'devise': 'EUR',
    'publie': true,
    'ordre': 1,
  });
  await db.doc('commerces/mama/produits/p2').set({
    'nom': 'Secret',
    'prix': 3,
    'devise': 'EUR',
    'publie': false,
    'ordre': 0,
  });
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets(
    'seuls les commerces publiés apparaissent, mieux notés d\'abord',
    (tester) async {
      ecranTelephone(tester);
      final banc = Banc();
      await preparer(banc);
      await banc.lancer(tester);
      expect(find.text('Chez Mama'), findsOneWidget);
      expect(find.text('Boutique Grâce'), findsOneWidget);
      expect(find.text('Pas Encore'), findsNothing);
      expect(
        tester.getTopLeft(find.text('Chez Mama')).dy,
        lessThan(tester.getTopLeft(find.text('Boutique Grâce')).dy),
      );
      expect(find.text('Vérifié'), findsNWidgets(2));
    },
  );

  testWidgets('recherche par début de mot, sans accent', (tester) async {
    ecranTelephone(tester);
    final banc = Banc();
    await preparer(banc);
    await banc.lancer(tester);
    await tester.enterText(find.byType(TextField), 'grac');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Boutique Grâce'), findsOneWidget);
    expect(find.text('Chez Mama'), findsNothing);

    await tester.enterText(find.byType(TextField), 'introuvable');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Aucun résultat'), findsOneWidget);
  });

  testWidgets('filtres : label chrétien, ouvert maintenant, continent', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = Banc();
    await preparer(banc);
    await banc.lancer(tester);

    await toucher(tester, find.widgetWithText(FilterChip, 'Chrétien'));
    expect(find.text('Boutique Grâce'), findsOneWidget);
    expect(find.text('Chez Mama'), findsNothing);
    await toucher(tester, find.widgetWithText(FilterChip, 'Chrétien'));

    // Lundi 10 h : Chez Mama est ouvert, Boutique Grâce n'a pas d'horaires.
    await toucher(tester, find.widgetWithText(FilterChip, 'Ouvert maintenant'));
    expect(find.text('Chez Mama'), findsOneWidget);
    expect(find.text('Boutique Grâce'), findsNothing);
    await toucher(tester, find.widgetWithText(FilterChip, 'Ouvert maintenant'));

    await toucher(tester, find.byTooltip('Filtres'));
    await toucher(tester, find.widgetWithText(ChoiceChip, 'Afrique'));
    await toucher(tester, find.text('Voir les résultats'));
    expect(find.text('Boutique Grâce'), findsOneWidget);
    expect(find.text('Chez Mama'), findsNothing);
  });

  testWidgets(
    'fiche : produits visibles seulement, appeler, itinéraire, infos',
    (tester) async {
      ecranTelephone(tester);
      final banc = Banc();
      await preparer(banc);
      await banc.lancer(tester);
      await toucher(tester, find.text('Chez Mama'));

      expect(find.text('Attiéké'), findsOneWidget);
      expect(find.textContaining('8,50'), findsOneWidget);
      expect(find.text('Secret'), findsNothing);

      await toucher(tester, find.byTooltip('Appeler'));
      await toucher(tester, find.byTooltip('Itinéraire'));
      expect(banc.lanceur.appels, [
        'tel:+33 4 00 00 00 00',
        'itineraire:45.76,4.83',
      ]);

      await toucher(tester, find.text('Infos'));
      expect(find.text('09:00-19:00'), findsOneWidget);
      expect(find.text('Ouvert'), findsWidgets);
    },
  );

  testWidgets('favori : connexion demandée, puis ajout et liste des favoris', (
    tester,
  ) async {
    ecranTelephone(tester);
    final invite = Banc();
    await preparer(invite);
    await invite.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.byTooltip('Ajouter aux favoris'));
    expect(find.text('Bienvenue sur Harambee'), findsOneWidget);
  });

  testWidgets('favori pour un utilisateur connecté', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte();
    await banc.firestore.doc('users/u1').update({'favoris': <String>[]});
    await preparer(banc);
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.byTooltip('Ajouter aux favoris'));
    expect(find.byTooltip('Retirer des favoris'), findsOneWidget);
    expect((await banc.firestore.doc('users/u1').get()).data()!['favoris'], [
      'mama',
    ]);

    await tester.tap(find.text('Favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Chez Mama'), findsOneWidget);
  });

  testWidgets('avis : note obligatoire, publication, modification', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = await bancConnecte();
    await preparer(banc);
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.text('Avis'));
    expect(
      find.text('Aucun avis pour l\'instant. Soyez le premier !'),
      findsOneWidget,
    );

    await toucher(tester, find.text('Donner mon avis'));
    await toucher(tester, find.text('Publier'));
    expect(find.text('Choisissez une note de 1 à 5 étoiles.'), findsOneWidget);
    await toucher(tester, find.byTooltip('4 étoiles'));
    await tester.enterText(find.byType(TextField), 'Très bon accueil');
    await toucher(tester, find.text('Publier'));

    final avis = (await banc.firestore.doc('commerces/mama/avis/u1').get())
        .data()!;
    expect(avis['note'], 4);
    expect(avis['auteur'], 'u1');
    expect(avis['auteurNom'], 'Awa');
    expect(find.text('Mon avis'), findsOneWidget);

    await toucher(tester, find.text('Modifier mon avis'));
    await toucher(tester, find.byTooltip('2 étoiles'));
    await toucher(tester, find.text('Publier'));
    expect(
      (await banc.firestore.doc('commerces/mama/avis/u1').get())
          .data()!['note'],
      2,
    );
  });

  testWidgets('le propriétaire ne peut pas noter son propre commerce', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore
        .doc('commerces/mien')
        .set(commerce('Mon Maquis', proprietaire: 'u1'));
    await banc.lancer(tester);
    await tester.tap(find.text('Explorer'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Mon Maquis'));
    await toucher(tester, find.text('Avis'));
    expect(find.text('Donner mon avis'), findsNothing);
  });

  testWidgets('signaler un commerce', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte();
    await preparer(banc);
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.byTooltip('Actions'));
    await toucher(tester, find.text('Signaler'));
    await tester.enterText(find.byType(TextFormField), 'Fausse adresse');
    await toucher(tester, find.text('Valider'));

    final s = (await banc.firestore.collection('signalements').get())
        .docs
        .single
        .data();
    expect(s['cible'], 'commerce');
    expect(s['cibleId'], 'mama');
    expect(s['auteur'], 'u1');
    expect(s['traite'], isFalse);
    expect(
      find.text('Merci. Notre équipe va examiner ce signalement.'),
      findsOneWidget,
    );
  });
}
