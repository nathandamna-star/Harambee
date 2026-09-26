import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers.dart';

Map<String, dynamic> commerce({String proprietaire = 'pro1'}) => {
  'nom': 'Chez Mama',
  'ville': 'Lyon',
  'categorie': 'restaurant',
  'continent': 'europe',
  'statut': 'publie',
  'proprietaire': proprietaire,
  'photos': <String>[],
};

Map<String, dynamic> conversation({int nonLusPro = 0, int nonLusClient = 0}) =>
    {
      'commerceId': 'mama',
      'commerceNom': 'Chez Mama',
      'clientId': 'client9',
      'clientNom': 'Kofi',
      'proId': 'u1',
      'participants': ['client9', 'u1'],
      'dernierMessage': 'Vous êtes ouverts dimanche ?',
      'nonLusClient': nonLusClient,
      'nonLusPro': nonLusPro,
      'updatedAt': Timestamp.fromDate(DateTime(2026, 9, 27, 18)),
    };

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('un client écrit à un commerce depuis sa fiche', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte();
    await banc.firestore.doc('commerces/mama').set(commerce());
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.widgetWithText(FilledButton, 'Message'));

    // Conversation créée, écran de conversation ouvert.
    final conv = (await banc.firestore.doc('conversations/mama__u1').get())
        .data()!;
    expect(conv['proId'], 'pro1');
    expect(conv['clientNom'], 'Awa');
    expect(conv['participants'], ['u1', 'pro1']);
    expect(find.text('Dites bonjour !'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Bonjour, avez-vous de l\'attiéké ?',
    );
    await toucher(tester, find.byTooltip('Envoyer'));
    expect(find.text('Bonjour, avez-vous de l\'attiéké ?'), findsOneWidget);

    final msgs = await banc.firestore
        .collection('conversations/mama__u1/messages')
        .get();
    expect(msgs.docs.single.data()['auteur'], 'u1');
    final apres = (await banc.firestore.doc('conversations/mama__u1').get())
        .data()!;
    expect(apres['dernierMessage'], 'Bonjour, avez-vous de l\'attiéké ?');
    expect(apres['nonLusPro'], 1);

    // Revenir sur la fiche et réécrire : même conversation.
    await toucher(tester, find.byType(BackButton));
    expect(find.text('Chez Mama'), findsOneWidget);
    expect(
      (await banc.firestore.collection('conversations').get()).docs,
      hasLength(1),
    );
  });

  testWidgets('le pro voit les non-lus, répond, et les compteurs suivent', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore
        .doc('conversations/mama__client9')
        .set(conversation(nonLusPro: 2));
    await banc.firestore.doc('conversations/mama__client9/messages/m1').set({
      'auteur': 'client9',
      'texte': 'Vous êtes ouverts dimanche ?',
      'createdAt': Timestamp.fromDate(DateTime(2026, 9, 27, 18)),
    });
    await banc.lancer(tester);

    expect(find.byTooltip('2 messages non lus'), findsOneWidget);
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Kofi'), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    await toucher(tester, find.text('Kofi'));
    expect(find.text('Vous êtes ouverts dimanche ?'), findsOneWidget);
    expect(
      (await banc.firestore.doc('conversations/mama__client9').get())
          .data()!['nonLusPro'],
      0,
    );

    await tester.enterText(find.byType(TextField), 'Oui, de 10 h à 16 h.');
    await toucher(tester, find.byTooltip('Envoyer'));
    final c = (await banc.firestore.doc('conversations/mama__client9').get())
        .data()!;
    expect(c['nonLusClient'], 1);
    expect(c['dernierMessage'], 'Oui, de 10 h à 16 h.');
  });

  testWidgets('envoi d\'une photo', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore.doc('conversations/mama__client9').set(conversation());
    await banc.lancer(tester);
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Kofi'));
    await toucher(tester, find.byTooltip('Envoyer une photo'));
    await toucher(tester, find.text('Choisir dans la galerie'));

    final m =
        (await banc.firestore
                .collection('conversations/mama__client9/messages')
                .get())
            .docs
            .single
            .data();
    expect(m['photoUrl'], isNotNull);
    expect(m['texte'], '');
    expect(
      (await banc.firestore.doc('conversations/mama__client9').get())
          .data()!['dernierMessage'],
      '📷 Photo',
    );
  });

  testWidgets('pas de message à son propre commerce', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore
        .doc('commerces/mama')
        .set(commerce(proprietaire: 'u1'));
    await banc.lancer(tester);
    await tester.tap(find.text('Explorer'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Chez Mama'));
    final bouton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Message'),
    );
    expect(bouton.onPressed, isNull);
  });

  testWidgets(
    'notifications : activées à la connexion, oubliées à la déconnexion',
    (tester) async {
      ecranTelephone(tester);
      final banc = await bancConnecte();
      await banc.lancer(tester);
      expect(banc.notifications.actives, ['u1']);
      await tester.tap(find.text('Mon espace'));
      await tester.pumpAndSettle();
      await toucher(tester, find.text('Se déconnecter'));
      expect(banc.notifications.desactivees, ['u1']);
    },
  );

  testWidgets('toucher une notification ouvre la conversation', (tester) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore.doc('conversations/mama__client9').set(conversation());
    await banc.lancer(tester);
    banc.notifications.touchees.add({'conversationId': 'mama__client9'});
    await tester.pumpAndSettle();
    expect(find.text('Kofi'), findsOneWidget);
    expect(find.byTooltip('Envoyer'), findsOneWidget);
  });
}
