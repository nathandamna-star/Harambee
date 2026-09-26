import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/features/admin/data/fonctions_admin.dart';

import '../../helpers.dart';

Map<String, dynamic> commerce(String nom, String statut) => {
  'nom': nom,
  'categorie': 'restaurant',
  'proprietaire': 'pro1',
  'continent': 'afrique',
  'pays': 'CI',
  'ville': 'Abidjan',
  'adresse': 'Cocody',
  'statut': statut,
  'labelAfricain': true,
  'labelChretien': true,
  'photos': <String>[],
};

Future<Banc> bancAdmin() async {
  final banc = await bancConnecte(claims: {'admin': true});
  await banc.firestore
      .doc('commerces/attente')
      .set(commerce('Maquis Awa', 'en_verification'));
  await banc.firestore
      .doc('commerces/publie')
      .set(commerce('Chez Kofi', 'publie'));
  return banc;
}

Future<void> ouvrirAdmin(WidgetTester tester) async {
  await tester.tap(find.text('Admin'));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('publier une fiche en retirant un label non justifié', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancAdmin();
    await banc.lancer(tester);
    await ouvrirAdmin(tester);

    expect(find.text('En attente (1)'), findsOneWidget);
    await toucher(tester, find.text('Maquis Awa'));
    expect(find.text('Charte chrétienne non signée'), findsOneWidget);

    // Label chrétien retiré : pas de charte signée.
    await toucher(
      tester,
      find.widgetWithText(SwitchListTile, 'Charte chrétienne non signée'),
    );
    await toucher(tester, find.text('Publier la fiche'));
    expect(find.text('Fiche publiée.'), findsOneWidget);

    final d = (await banc.firestore.doc('commerces/attente').get()).data()!;
    expect(d['statut'], 'publie');
    expect(d['labelAfricain'], isTrue);
    expect(d['labelChretien'], isFalse);
    expect(d['verifieLe'], isNotNull);
  });

  testWidgets('refuser exige un motif, visible ensuite', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancAdmin();
    await banc.lancer(tester);
    await ouvrirAdmin(tester);
    await toucher(tester, find.text('Maquis Awa'));

    await toucher(tester, find.widgetWithText(OutlinedButton, 'Refuser'));
    await toucher(tester, find.text('Valider'));
    expect(find.text('Ce champ est obligatoire.'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Photos manquantes');
    await toucher(tester, find.text('Valider'));

    final d = (await banc.firestore.doc('commerces/attente').get()).data()!;
    expect(d['statut'], 'suspendu');
    expect(d['motifRefus'], 'Photos manquantes');
    expect(find.text('Motif : Photos manquantes'), findsOneWidget);
    expect(find.text('Republier la fiche'), findsOneWidget);
  });

  testWidgets('suspendre une fiche publiée', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancAdmin();
    await banc.lancer(tester);
    await ouvrirAdmin(tester);
    await toucher(tester, find.text('Publiés'));
    await toucher(tester, find.text('Chez Kofi'));
    await toucher(tester, find.text('Suspendre la fiche'));
    await tester.enterText(find.byType(TextFormField), 'Signalements répétés');
    await toucher(tester, find.text('Valider'));
    final d = (await banc.firestore.doc('commerces/publie').get()).data()!;
    expect(d['statut'], 'suspendu');
  });

  testWidgets('signalements : marquer comme traité', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancAdmin();
    await banc.firestore.doc('signalements/s1').set({
      'auteur': 'client1',
      'cible': 'avis',
      'cibleId': 'commerces/publie/avis/client1',
      'motif': 'Propos insultants',
      'traite': false,
    });
    await banc.lancer(tester);
    await ouvrirAdmin(tester);
    await toucher(tester, find.text('Signalements (1)'));
    expect(find.text('Propos insultants'), findsOneWidget);
    await toucher(tester, find.text('Marquer comme traité'));
    expect(find.text('Aucun signalement à traiter.'), findsOneWidget);
    expect(
      (await banc.firestore.doc('signalements/s1').get()).data()!['traite'],
      isTrue,
    );
  });

  testWidgets(
    'nommer un administrateur, et message clair si le compte est inconnu',
    (tester) async {
      ecranTelephone(tester, grand: true);
      final banc = await bancAdmin();
      await banc.lancer(tester);
      await ouvrirAdmin(tester);
      await toucher(tester, find.byTooltip('Administrateurs'));

      await tester.enterText(find.byType(TextFormField), 'kofi@exemple.com');
      await toucher(tester, find.text('Nommer administrateur'));
      expect(banc.fonctionsAdmin.appels, ['definir:kofi@exemple.com:true']);
      expect(
        find.textContaining('kofi@exemple.com est maintenant administrateur'),
        findsOneWidget,
      );

      banc.fonctionsAdmin.erreur = ErreurAdmin.compteIntrouvable;
      await tester.enterText(
        find.byType(TextFormField),
        'personne@exemple.com',
      );
      await toucher(tester, find.text('Nommer administrateur'));
      expect(
        find.text('Aucun compte Harambee avec cette adresse e-mail.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('activation du premier administrateur par appui long', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();

    banc.fonctionsAdmin.erreur = ErreurAdmin.nonAutorise;
    await tester.longPress(find.text('Bonjour Awa'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Valider'));
    expect(
      find.text('Ce compte n\'est pas autorisé à faire cette action.'),
      findsOneWidget,
    );

    banc.fonctionsAdmin.erreur = null;
    await tester.longPress(find.text('Bonjour Awa'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Valider'));
    expect(banc.fonctionsAdmin.appels, ['revendiquer', 'revendiquer']);
    expect(
      find.textContaining('Vous êtes maintenant administrateur'),
      findsOneWidget,
    );
  });

  testWidgets('un non-administrateur n\'a pas accès à l\'admin', (
    tester,
  ) async {
    final banc = await bancConnecte(role: 'pro');
    await banc.lancer(tester);
    expect(find.text('Admin'), findsNothing);
  });
}
