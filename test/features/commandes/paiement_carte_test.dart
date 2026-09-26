import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/features/commandes/data/paiement_service.dart';

import '../../helpers.dart';
import 'commande_test.dart' show preparerCommerce, seedCommande;

Future<void> commanderParCarte(WidgetTester tester, Banc banc) async {
  await banc.firestore.doc('commerces/mama').update({
    'paiementCarteActif': true,
  });
  await banc.lancer(tester);
  await toucher(tester, find.text('Chez Mama'));
  await toucher(tester, find.text('Ajouter au panier'));
  await toucher(tester, find.byTooltip('Ajouter un'));
  await toucher(tester, find.textContaining('Voir le panier'));
  await toucher(tester, find.text('Carte bancaire ou Bancontact'));
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Téléphone'),
    '0470000000',
  );
  await toucher(tester, find.textContaining('Commander ·'));
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('carte proposée seulement si le commerce l\'a activée', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await preparerCommerce(banc);
    await banc.lancer(tester);
    await toucher(tester, find.text('Chez Mama'));
    await toucher(tester, find.text('Ajouter au panier'));
    await toucher(tester, find.textContaining('Voir le panier'));
    expect(find.text('Carte bancaire ou Bancontact'), findsNothing);
    expect(find.text('Espèces au retrait'), findsOneWidget);
  });

  testWidgets('paiement réussi, puis confirmation par Stripe', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    await preparerCommerce(banc);
    await commanderParCarte(tester, banc);

    expect(banc.fonctionsCommande.demandes.single.methode.name, 'carte');
    expect(banc.paiement.secrets, ['secret']);
    expect(find.text('Paiement : en attente'), findsOneWidget);

    // Le webhook Stripe marque la commande payée.
    await banc.firestore.doc('commandes/cmd123456').update({
      'paiement.statut': 'paye',
    });
    await tester.pumpAndSettle();
    expect(find.text('Paiement : payé'), findsOneWidget);
    expect(find.text('Payer maintenant'), findsNothing);
  });

  testWidgets('paiement abandonné : message, puis « Payer maintenant »', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte();
    banc.paiement.resultat = ResultatPaiement.annule;
    await preparerCommerce(banc);
    await commanderParCarte(tester, banc);
    expect(find.textContaining('Paiement non terminé'), findsOneWidget);

    banc.paiement.resultat = ResultatPaiement.reussi;
    await toucher(tester, find.text('Payer maintenant'));
    expect(banc.paiement.secrets.last, 'secret-cmd123456');
  });

  testWidgets('le pro ne voit une commande par carte qu\'une fois payée', (
    tester,
  ) async {
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
    await seedCommande(banc, id: 'carte001');
    await banc.firestore.doc('commandes/carte001').update({
      'paiement': {
        'methode': 'carte',
        'statut': 'en_attente',
        'reference': 'pi_1',
      },
    });
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nouvelle commande'), findsNothing);

    await banc.firestore.doc('commandes/carte001').update({
      'paiement.statut': 'paye',
    });
    await tester.pumpAndSettle();
    expect(find.text('1 nouvelle commande'), findsOneWidget);
  });

  testWidgets('le pro active le paiement par carte (formulaire Stripe)', (
    tester,
  ) async {
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
    await toucher(tester, find.text('Activer le paiement par carte'));
    expect(banc.fonctionsCommande.liensDemandes, ['c1']);
    expect(banc.lanceur.appels, [
      'ouvrir:https://connect.stripe.com/setup/e/c1',
    ]);
  });

  testWidgets('tarifs : frais de paiement par carte enregistrés', (
    tester,
  ) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte(claims: {'admin': true});
    await banc.lancer(tester);
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    await toucher(tester, find.byTooltip('Tarifs'));
    await toucher(tester, find.text('Enregistrer'));
    final t = (await banc.firestore.doc('parametres/tarifs').get()).data()!;
    expect(t['paiementCarte'], {'pct': 1.5, 'fixe': 0.25});
  });
}
