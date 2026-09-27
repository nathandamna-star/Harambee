import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helpers.dart';

Future<void> commandeTerminee(
  Banc banc,
  String id, {
  String methode = 'especes',
  String statutPaiement = 'en_attente',
  String proId = 'u1',
  String commerce = 'Chez Mama',
}) => banc.firestore.doc('commandes/$id').set({
  'commerceId': commerce.toLowerCase(),
  'commerceNom': commerce,
  'clientId': 'client9',
  'clientNom': 'Kofi',
  'proId': proId,
  'pays': 'BE',
  'lignes': <Map<String, dynamic>>[],
  'sousTotal': 17,
  'fraisLivraison': 0,
  'fraisService': 0.69,
  'commissionPlateforme': 1.19,
  'fraisPaiement': methode == 'carte' ? 0.52 : 0,
  'total': 17.69,
  'devise': 'EUR',
  'mode': 'emporter',
  'telephoneClient': '',
  'paiement': {'methode': methode, 'statut': statutPaiement},
  'statut': 'retiree',
  'historique': <Map<String, dynamic>>[],
  'createdAt': Timestamp.fromDate(DateTime(2026, 9, 12)),
});

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('admin : revenus du mois et montants à facturer', (tester) async {
    ecranTelephone(tester, grand: true);
    final banc = await bancConnecte(claims: {'admin': true});
    await commandeTerminee(banc, 'a1');
    await commandeTerminee(
      banc,
      'a2',
      methode: 'carte',
      statutPaiement: 'paye',
    );
    await commandeTerminee(banc, 'a3', commerce: 'Chez Kofi');
    await banc.lancer(tester);
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle();
    await toucher(tester, find.byTooltip('Revenus'));

    expect(find.text('2026'), findsOneWidget);
    expect(find.text('septembre 2026'), findsOneWidget);
    await toucher(tester, find.text('septembre 2026'));
    // 3 × 1,19 de commission, 3 × 0,69 de frais de service.
    expect(find.textContaining('3,57'), findsOneWidget);
    expect(find.textContaining('2,07'), findsOneWidget);
    expect(find.text('À facturer (commandes en espèces)'), findsOneWidget);
    expect(find.text('Chez Mama'), findsOneWidget);
    expect(find.text('Chez Kofi'), findsOneWidget);
  });

  testWidgets('pro : récapitulatif mensuel et téléchargement CSV', (
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
    await commandeTerminee(banc, 'b1');
    await commandeTerminee(
      banc,
      'b2',
      methode: 'carte',
      statutPaiement: 'paye',
    );
    await banc.lancer(tester);
    await tester.tap(find.text('Mon espace'));
    await tester.pumpAndSettle();
    await toucher(tester, find.text('Commandes'));
    await toucher(tester, find.byTooltip('Récapitulatif mensuel'));

    // Net : 15,81 (espèces) + 15,29 (carte) ; dû sur espèces : 1,88.
    expect(find.textContaining('31,10'), findsOneWidget);
    expect(find.textContaining('15,29'), findsOneWidget);
    expect(find.text('À régler à Harambee'), findsOneWidget);
    expect(find.textContaining('1,88'), findsOneWidget);

    await toucher(tester, find.text('Télécharger (tableur CSV)'));
    final csv = banc.partage.fichiers['harambee-2026-09.csv']!;
    expect(csv.split('\n').first, startsWith('Date;Numéro;Client;Paiement'));
    expect(csv.trim().split('\n'), hasLength(3));
  });
}
