import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/app.dart';
import 'package:harambee/core/auth/role.dart';

Future<void> lancer(
  WidgetTester tester, {
  Role role = Role.client,
  Locale locale = const Locale('fr'),
}) async {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [roleProvider.overrideWithValue(role)],
      child: const HarambeeApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('démarre sur Explorer avec 4 onglets pour un client', (
    tester,
  ) async {
    await lancer(tester);
    expect(find.text('Trouvez un commerce près de chez vous'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.text('Admin'), findsNothing);
    expect(find.text('Africain'), findsOneWidget);
    expect(find.text('Chrétien'), findsOneWidget);
  });

  testWidgets('la navigation change d\'écran', (tester) async {
    await lancer(tester);
    await tester.tap(find.text('Favoris'));
    await tester.pumpAndSettle();
    expect(find.text('Aucun favori pour l\'instant'), findsOneWidget);

    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(find.text('Aucune conversation'), findsOneWidget);

    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();
    expect(find.text('Votre espace'), findsOneWidget);
  });

  testWidgets('un administrateur voit l\'onglet Admin', (tester) async {
    await lancer(tester, role: Role.admin);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    expect(find.text('Administration'), findsWidgets);
  });

  testWidgets('traduit en anglais', (tester) async {
    await lancer(tester, locale: const Locale('en'));
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('African'), findsOneWidget);
  });

  testWidgets('traduit en portugais', (tester) async {
    await lancer(tester, locale: const Locale('pt', 'BR'));
    expect(find.text('Explorar'), findsOneWidget);
    expect(find.text('Cristão'), findsOneWidget);
  });

  testWidgets('langue non prise en charge : français par défaut', (
    tester,
  ) async {
    await lancer(tester, locale: const Locale('de'));
    expect(find.text('Explorer'), findsOneWidget);
  });
}
