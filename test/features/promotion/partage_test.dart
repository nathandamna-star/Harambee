import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../helpers.dart';

const lienMama =
    'https://europe-west1-harambee-75bab.cloudfunctions.net/commerce?id=mama';

Map<String, dynamic> commerce({String statut = 'publie'}) => {
  'nom': 'Chez Mama',
  'categorie': 'restaurant',
  'continent': 'europe',
  'ville': 'Bruxelles',
  'statut': statut,
  'proprietaire': 'u1',
  'devise': 'EUR',
  'photos': <String>[],
};

GoRouter routeur(WidgetTester tester) =>
    GoRouter.of(tester.element(find.byType(Scaffold).first));

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('partager un commerce depuis sa fiche', (tester) async {
    ecranTelephone(tester);
    final banc = Banc();
    await banc.firestore.doc('commerces/mama').set({
      ...commerce(),
      'proprietaire': 'pro1',
    });
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.byTooltip('Partager'));
    expect(banc.partage.textes, [
      'Découvrez Chez Mama sur Harambee : $lienMama',
    ]);
  });

  testWidgets('site web du commerce : bouton sur la fiche', (tester) async {
    ecranTelephone(tester);
    final banc = Banc();
    await banc.firestore.doc('commerces/mama').set({
      ...commerce(),
      'proprietaire': 'pro1',
      'siteWeb': 'https://www.chezmama.be',
    });
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.byTooltip('Site web'));
    expect(banc.lanceur.appels, ['ouvrir:https://www.chezmama.be']);
  });

  testWidgets('lien profond vers une fiche, lien inconnu vers Explorer', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = Banc();
    await banc.firestore.doc('commerces/mama').set({
      ...commerce(),
      'proprietaire': 'pro1',
    });
    await banc.lancer(tester);

    routeur(tester).go('/explorer/commerce/mama');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Partager'), findsOneWidget);

    routeur(tester).go('/stripe-redirect');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Partager'), findsNothing);
    expect(find.text('Chez Mama'), findsOneWidget);
  });

  testWidgets('affiche QR code : lien et image partagés', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore.doc('commerces/mama').set(commerce());
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();

    await toucher(tester, find.text('Affiche et lien à partager'));
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, lienMama);
    expect(find.text('Retrouvez-nous sur Harambee'), findsOneWidget);

    await toucher(tester, find.text('Partager le lien'));
    expect(banc.partage.textes.single, contains(lienMama));

    await tester.runAsync(() async {
      await tester.tap(find.text('Partager ou imprimer l\'affiche'));
      for (var i = 0; i < 50 && banc.partage.images.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    final png = banc.partage.images['affiche-harambee.png']!;
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
  });

  testWidgets('pas d\'affiche tant que le commerce n\'est pas publié', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = await bancConnecte(role: 'pro');
    await banc.firestore
        .doc('commerces/mama')
        .set(commerce(statut: 'en_verification'));
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();
    expect(find.text('Affiche et lien à partager'), findsNothing);

    routeur(tester).push('/mon-espace/commerce/mama/affiche');
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsNothing);
    expect(find.textContaining('dès que votre commerce sera publié'), findsOne);
  });
}
