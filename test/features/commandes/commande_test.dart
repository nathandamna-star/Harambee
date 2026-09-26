import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/features/commandes/data/commandes_repository.dart';
import 'package:harambee/shared/models/commande.dart';

import '../../helpers.dart';

Future<void> preparerCommerce(Banc banc, {String proprietaire = 'pro1'}) async {
  await banc.firestore.doc('parametres/tarifs').set({
    'parPays': {
      'BE': {'commissionPct': 7, 'fraisServiceFixe': 0.69},
    },
  });
  await banc.firestore.doc('commerces/mama').set({
    'nom': 'Chez Mama',
    'ville': 'Bruxelles',
    'pays': 'BE',
    'continent': 'europe',
    'categorie': 'restaurant',
    'statut': 'publie',
    'proprietaire': proprietaire,
    'devise': 'EUR',
    'geo': const GeoPoint(50.8466, 4.3528),
    'photos': <String>[],
    'commande': {
      'active': true,
      'modes': ['emporter', 'livraison'],
      'minimumCommande': 10,
      'minimumLivraison': 20,
      'fraisLivraison': 3.5,
      'rayonLivraisonKm': 5,
      'especesAcceptees': true,
      'devise': 'EUR',
    },
  });
  await banc.firestore.doc('commerces/mama/produits/attieke').set({
    'nom': 'Attiéké',
    'prix': 8.5,
    'devise': 'EUR',
    'publie': true,
    'ordre': 0,
  });
  await banc.firestore.doc('commerces/mama/produits/garba').set({
    'nom': 'Garba',
    'prix': 3,
    'devise': 'EUR',
    'publie': true,
    'ordre': 1,
    'enRupture': true,
  });
}

Future<void> seedCommande(
  Banc banc, {
  String id = 'aaa111xx',
  String statut = 'nouvelle',
  String proId = 'u1',
  String clientId = 'client9',
}) => banc.firestore.doc('commandes/$id').set({
  'commerceId': 'mama',
  'commerceNom': 'Chez Mama',
  'clientId': clientId,
  'clientNom': 'Kofi',
  'proId': proId,
  'lignes': [
    {
      'produitId': 'attieke',
      'nom': 'Attiéké',
      'prixUnitaire': 8.5,
      'quantite': 2,
    },
  ],
  'sousTotal': 17,
  'fraisLivraison': 0,
  'fraisService': 0.69,
  'commissionPlateforme': 1.19,
  'fraisPaiement': 0,
  'total': 17.69,
  'devise': 'EUR',
  'mode': 'emporter',
  'telephoneClient': '+32 470 11 22 33',
  'paiement': {'methode': 'especes', 'statut': 'en_attente'},
  'statut': statut,
  'historique': [
    {'statut': 'nouvelle', 'date': Timestamp.fromDate(maintenantTest)},
  ],
  'createdAt': Timestamp.fromDate(maintenantTest),
});

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('client : panier, minimum, commande en espèces, suivi', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await preparerCommerce(banc);
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));

    // Produit en rupture : pas de bouton d'ajout.
    expect(find.text('Ajouter au panier'), findsOneWidget);
    await toucher(tester, find.text('Ajouter au panier'));
    expect(find.textContaining('Voir le panier (1)'), findsOneWidget);
    await toucher(tester, find.textContaining('Voir le panier'));

    // 8,50 € < 10 € : bouton désactivé, montant manquant affiché.
    expect(find.textContaining('Encore 1,50'), findsOneWidget);
    final bouton = find.ancestor(
      of: find.textContaining('9,19'),
      matching: find.byType(FilledButton),
    );
    expect(tester.widget<FilledButton>(bouton).onPressed, isNull);

    await toucher(tester, find.byTooltip('Ajouter un'));
    expect(find.textContaining('Encore'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Téléphone'),
      '+32 470 00 00 00',
    );
    await toucher(tester, find.textContaining('Commander · 17,69'));

    final demande = banc.fonctionsCommande.demandes.single;
    expect(demande.lignes, {'attieke': 2});
    expect(demande.mode, ModeCommande.emporter);
    expect(demande.methode, MethodePaiement.especes);
    expect(demande.telephone, '+32 470 00 00 00');

    // Suivi de la commande.
    expect(find.text('Commande #CMD123'), findsOneWidget);
    expect(find.text('Commande envoyée'), findsOneWidget);
    await toucher(tester, find.text('Annuler la commande'));
    await toucher(
      tester,
      find.widgetWithText(FilledButton, 'Annuler la commande'),
    );
    final c = (await banc.firestore.doc('commandes/cmd123456').get()).data()!;
    expect(c['statut'], 'annulee');
    expect((c['historique'] as List).length, 2);
  });

  testWidgets('livraison : position exigée, erreur hors zone expliquée', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await preparerCommerce(banc);
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.text('Ajouter au panier'));
    for (var i = 0; i < 2; i++) {
      await toucher(tester, find.byTooltip('Ajouter un'));
    }
    await toucher(tester, find.textContaining('Voir le panier'));
    await toucher(tester, find.text('Livraison'));
    expect(find.text('Frais de livraison'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse de livraison'),
      'Rue Haute 1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Téléphone'),
      '0470000000',
    );
    await toucher(tester, find.textContaining('Commander'));
    expect(find.textContaining('Enregistrez votre position'), findsOneWidget);

    await toucher(
      tester,
      find.text('Enregistrer ma position pour la livraison'),
    );
    banc.fonctionsCommande.erreur = const ErreurCommande('hors-zone');
    await toucher(tester, find.textContaining('Commander'));
    expect(find.textContaining('hors de la zone de livraison'), findsOneWidget);
    expect(banc.fonctionsCommande.demandes.last.adresseGeo, isNotNull);
  });

  testWidgets('pro : réglages de commande enregistrés', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore.doc('commerces/c1').set({
      'nom': 'Chez Awa',
      'proprietaire': 'u1',
      'statut': 'publie',
      'categorie': 'restaurant',
      'continent': 'europe',
      'devise': 'EUR',
      'photos': <String>[],
    });
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Activer la commande en ligne'));
    await toucher(
      tester,
      find.widgetWithText(SwitchListTile, 'Activer la commande en ligne'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Minimum de commande'),
      '12,50',
    );
    await toucher(tester, find.text('Enregistrer'));
    final r =
        (await banc.firestore.doc('commerces/c1').get()).data()!['commande']
            as Map;
    expect(r['active'], isTrue);
    expect(r['minimumCommande'], 12.5);
    expect(r['modes'], ['emporter']);
    expect(r['especesAcceptees'], isTrue);
  });

  testWidgets(
    'pro : nouvelle commande, montant net, accepter puis préparer, refuser',
    (tester) async {
      ecranTelephone(tester, grand: true);
      final banc = await bancConnecte(role: 'pro');
      await banc.firestore.doc('commerces/mama').set({
        'nom': 'Chez Mama',
        'proprietaire': 'u1',
        'statut': 'publie',
        'categorie': 'restaurant',
        'continent': 'europe',
        'photos': <String>[],
      });
      await seedCommande(banc);
      await seedCommande(banc, id: 'bbb222xx');
      await banc.lancer(tester);
      await tester.tap(find.text('Mon espace'));
      await tester.pumpAndSettle();
      expect(find.text('2 nouvelles commandes'), findsOneWidget);
      await toucher(tester, find.text('Commandes'));
      await toucher(tester, find.textContaining('#AAA111'));

      // Transparence : 17,69 − 0,69 − 1,19 − 0 = 15,81 €.
      expect(find.textContaining('15,81'), findsOneWidget);
      expect(find.textContaining('À encaisser en espèces'), findsOneWidget);

      await toucher(tester, find.text('Accepter la commande'));
      await toucher(tester, find.text('Commencer la préparation'));
      var c = (await banc.firestore.doc('commandes/aaa111xx').get()).data()!;
      expect(c['statut'], 'en_preparation');
      expect((c['historique'] as List).map((e) => e['statut']), [
        'nouvelle',
        'acceptee',
        'en_preparation',
      ]);
      expect(find.text('Commande prête'), findsWidgets);

      await toucher(tester, find.byType(BackButton));
      await toucher(tester, find.textContaining('#BBB222'));
      await toucher(tester, find.text('Refuser la commande'));
      await tester.enterText(find.byType(TextFormField), 'Rupture de stock');
      await toucher(tester, find.text('Valider'));
      c = (await banc.firestore.doc('commandes/bbb222xx').get()).data()!;
      expect(c['statut'], 'refusee');
      expect(c['motifRefus'], 'Rupture de stock');
    },
  );

  testWidgets('admin : tarifs enregistrés', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte(claims: {'admin': true});
    await banc.lancer(tester);
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    await toucher(tester, find.byTooltip('Tarifs'));
    debugPrint(
      'TEXTES: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).take(30).toList()}',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Commission').first,
      '7',
    );
    await toucher(tester, find.text('Enregistrer'));
    final t = (await banc.firestore.doc('parametres/tarifs').get()).data()!;
    expect(t['defaut']['commissionPct'], 7);
    expect(t['defaut']['fraisServiceFixe'], 0.49);
    expect(t['lancement']['dureeMois'], 6);
  });

  testWidgets('toucher la notification d\'une commande l\'ouvre', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await seedCommande(banc, proId: 'pro1', clientId: 'u1');
    await banc.lancer(tester);
    banc.notifications.touchees.add({'commandeId': 'aaa111xx'});
    await tester.pumpAndSettle();
    expect(find.text('Commande #AAA111'), findsOneWidget);
  });
}
