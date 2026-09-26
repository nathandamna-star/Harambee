import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'helpers.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('navigation', () {
    testWidgets('premier lancement : écran de bienvenue', (tester) async {
      await Banc().lancer(tester, bienvenueVue: false);
      expect(find.text('Bienvenue sur Harambee'), findsOneWidget);
      expect(find.text('Je cherche un commerce'), findsOneWidget);
      expect(find.text('J\'ai un commerce'), findsOneWidget);
    });

    testWidgets('explorer sans compte', (tester) async {
      await Banc().lancer(tester, bienvenueVue: false);
      await tester.tap(find.text('Explorer sans compte'));
      await tester.pumpAndSettle();
      expect(
        find.text('Trouvez un commerce près de chez vous'),
        findsOneWidget,
      );
      expect(find.byType(NavigationDestination), findsNWidgets(4));
    });

    testWidgets('sans compte, Favoris invite à se connecter', (tester) async {
      await Banc().lancer(tester);
      await tester.tap(find.text('Favoris'));
      await tester.pumpAndSettle();
      expect(find.text('Connectez-vous'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
      await tester.pumpAndSettle();
      expect(find.text('Bienvenue sur Harambee'), findsOneWidget);
    });

    testWidgets('client connecté : 4 onglets, écrans accessibles', (
      tester,
    ) async {
      await (await bancConnecte()).lancer(tester);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.text('Admin'), findsNothing);

      await tester.tap(find.text('Favoris'));
      await tester.pumpAndSettle();
      expect(find.text('Aucun favori pour l\'instant'), findsOneWidget);

      await tester.tap(find.text('Messages'));
      await tester.pumpAndSettle();
      expect(find.text('Aucune conversation'), findsOneWidget);

      await tester.tap(find.text('Mon espace'));
      await tester.pumpAndSettle();
      expect(find.text('Bonjour Awa'), findsOneWidget);
      expect(find.text('Client'), findsOneWidget);
    });

    testWidgets('administrateur (custom claim) : onglet Admin', (tester) async {
      await (await bancConnecte(claims: {'admin': true})).lancer(tester);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();
      expect(find.text('Administration'), findsWidgets);
    });

    testWidgets('« admin » écrit dans le profil ne donne pas l\'accès admin', (
      tester,
    ) async {
      await (await bancConnecte(role: 'admin')).lancer(tester);
      expect(find.byType(NavigationDestination), findsNWidgets(4));
      expect(find.text('Admin'), findsNothing);
    });
  });

  group('langues', () {
    testWidgets('anglais', (tester) async {
      await Banc().lancer(tester, locale: const Locale('en'));
      expect(find.text('Explore'), findsOneWidget);
      expect(find.text('African'), findsOneWidget);
    });

    testWidgets('portugais', (tester) async {
      await Banc().lancer(tester, locale: const Locale('pt', 'BR'));
      expect(find.text('Explorar'), findsOneWidget);
      expect(find.text('Cristão'), findsOneWidget);
    });

    testWidgets('langue non prise en charge : français', (tester) async {
      await Banc().lancer(tester, locale: const Locale('de'));
      expect(find.text('Explorer'), findsOneWidget);
    });
  });
}
