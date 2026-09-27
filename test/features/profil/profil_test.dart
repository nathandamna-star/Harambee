import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/features/profil/compte_service.dart';

import '../../helpers.dart';

Future<void> ouvrirProfil(WidgetTester tester) async {
  await tester.tap(find.text('Mon espace'));
  await tester.pumpAndSettle();
  await toucher(tester, find.text('Profil et réglages'));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('langue : l\'app passe en anglais, le profil est mis à jour', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await ouvrirProfil(tester);
    await toucher(tester, find.text('Celle du téléphone'));
    await toucher(tester, find.text('English').last);
    expect(find.text('Profile and settings'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(
      (await banc.firestore.doc('users/u1').get()).data()!['langue'],
      'en',
    );
  });

  testWidgets('nom et devise préférée', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await ouvrirProfil(tester);
    await toucher(tester, find.text('Awa'));
    await tester.enterText(find.byType(TextField), 'Awa Diallo');
    await toucher(tester, find.text('Enregistrer'));
    await toucher(tester, find.byType(DropdownButton<String?>).last);
    await toucher(tester, find.text('XOF').last);
    final profil = (await banc.firestore.doc('users/u1').get()).data()!;
    expect(profil['nom'], 'Awa Diallo');
    expect(profil['devise'], 'XOF');
  });

  testWidgets('suppression : confirmation écrite, puis déconnexion', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await ouvrirProfil(tester);
    await toucher(tester, find.text('Supprimer mon compte'));
    final bouton = find.widgetWithText(
      FilledButton,
      'Supprimer définitivement',
    );
    expect(tester.widget<FilledButton>(bouton).onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'supprimer');
    await tester.pump();
    await toucher(tester, bouton);

    expect(banc.compte.appels, 1);
    expect(banc.notifications.desactivees, ['u1']);
    expect(banc.auth.currentUser, isNull);
    expect(find.text('Votre compte a été supprimé.'), findsOneWidget);
  });

  testWidgets('suppression refusée avec des commandes en cours', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    banc.compte.erreur = const ErreurSuppression('commandes-en-cours');
    await banc.lancer(tester);
    await ouvrirProfil(tester);
    await toucher(tester, find.text('Supprimer mon compte'));
    await tester.enterText(find.byType(TextField), 'SUPPRIMER');
    await tester.pump();
    await toucher(tester, find.text('Supprimer définitivement'));
    expect(find.textContaining('commandes en cours'), findsOneWidget);
    expect(banc.auth.currentUser, isNotNull);
  });

  testWidgets('pages légales accessibles sans compte depuis l\'accueil', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    await Banc().lancer(tester, bienvenueVue: false);
    await toucher(tester, find.text('Politique de confidentialité'));
    expect(find.text('1. Qui sommes-nous ?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('Autorité de protection des données'),
      300,
    );
    await toucher(tester, find.byType(BackButton));
    await toucher(tester, find.text('Conditions d\'utilisation'));
    expect(find.text('Conditions générales d\'utilisation'), findsOneWidget);
    expect(find.textContaining('MODÈLE À COMPLÉTER'), findsOneWidget);
  });
}
