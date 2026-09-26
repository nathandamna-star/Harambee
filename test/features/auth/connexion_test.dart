import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import '../../helpers.dart';

Future<void> ouvrirEmail(WidgetTester tester, {bool pro = false}) async {
  if (pro) {
    await tester.tap(find.text('J\'ai un commerce'));
    await tester.pumpAndSettle();
  }
  final bouton = find.text('Continuer avec l\'e-mail');
  await tester.ensureVisible(bouton);
  await tester.pumpAndSettle();
  await tester.tap(bouton);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('inscription pro par e-mail : profil « pro » puis Mon espace', (
    tester,
  ) async {
    final banc = Banc();
    await banc.lancer(tester, bienvenueVue: false);
    await ouvrirEmail(tester, pro: true);

    await tester.tap(find.text('Créer un compte').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom'),
      'Chez Mama',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse e-mail'),
      'mama@exemple.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'motdepasse1',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Créer un compte'));
    await tester.pumpAndSettle();

    final uid = banc.auth.currentUser!.uid;
    final profil = await banc.firestore.collection('users').doc(uid).get();
    expect(profil.data()!['role'], 'pro');
    expect(profil.data()!['nom'], 'Chez Mama');
    expect(profil.data()!['email'], 'mama@exemple.com');

    expect(find.text('Bonjour Chez Mama'), findsOneWidget);
    expect(find.text('Professionnel'), findsOneWidget);
  });

  testWidgets('formulaire : champs invalides signalés', (tester) async {
    await Banc().lancer(tester, bienvenueVue: false);
    await ouvrirEmail(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse e-mail'),
      'pas-un-email',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'court',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Indiquez une adresse e-mail valide.'), findsOneWidget);
    expect(find.text('Au moins 8 caractères.'), findsOneWidget);
  });

  testWidgets('mauvais mot de passe : message clair', (tester) async {
    final banc = Banc();
    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(banc.auth)
        .thenThrow(FirebaseAuthException(code: 'invalid-credential'));
    await banc.lancer(tester, bienvenueVue: false);
    await ouvrirEmail(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Adresse e-mail'),
      'awa@exemple.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'mauvais-mdp',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(
      find.text('Adresse e-mail ou mot de passe incorrect.'),
      findsOneWidget,
    );
    expect(banc.auth.currentUser, isNull);
  });

  testWidgets('connexion Google : profil client créé, retour à Explorer', (
    tester,
  ) async {
    final banc = Banc();
    await banc.lancer(tester, bienvenueVue: false);
    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();

    expect(banc.google.connecte, isTrue);
    final uid = banc.auth.currentUser!.uid;
    final profil = await banc.firestore.collection('users').doc(uid).get();
    expect(profil.data()!['role'], 'client');
    expect(find.text('Trouvez un commerce près de chez vous'), findsOneWidget);
  });

  testWidgets('déconnexion', (tester) async {
    final banc = await bancConnecte();
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(banc.auth.currentUser, isNull);
    expect(find.text('Connectez-vous'), findsOneWidget);
  });
}
