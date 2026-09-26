import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:harambee/features/commerce/data/localisation_service.dart';
import 'package:harambee/features/explorer/data/explorer_repository.dart';
import 'package:harambee/shared/models/recherche.dart';

import '../../helpers.dart';

/// Commerces autour d'Abidjan (position simulée : 5.32, -4.02).
Future<void> preparer(FakeFirebaseFirestore db) async {
  Future<void> ajouter(
    String id,
    String nom,
    double lat,
    double lon, {
    String statut = 'publie',
    bool chretien = false,
  }) => db.doc('commerces/$id').set({
    'nom': nom,
    'ville': 'Abidjan',
    'motsCles': motsClesRecherche([nom, 'Abidjan']),
    'categorie': 'restaurant',
    'continent': 'afrique',
    'statut': statut,
    'labelAfricain': true,
    'labelChretien': chretien,
    'geo': GeoPoint(lat, lon),
    'geohash': GeoHasher().encode(lon, lat, precision: 9),
    'proprietaire': 'pro1',
    'photos': <String>[],
  });
  await ajouter('tout-pres', 'Maquis du Plateau', 5.325, -4.02); // ~0,6 km
  await ajouter('proche', 'Chez Tanti', 5.35, -3.99, chretien: true); // ~4,7 km
  await ajouter('loin', 'Grand-Bassam Grill', 5.20, -3.74); // ~34 km
  await ajouter(
    'attente',
    'Pas Publié',
    5.321,
    -4.021,
    statut: 'en_verification',
  );
  await db.doc('commerces/sans-position').set({
    'nom': 'Sans Position',
    'statut': 'publie',
    'categorie': 'magasin',
    'continent': 'afrique',
  });
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('repository : dans le rayon, du plus proche au plus loin', () async {
    final db = FakeFirebaseFirestore();
    await preparer(db);
    final repo = ExplorerRepository(db);
    final centre = const GeoPoint(5.32, -4.02);

    final a5 = await repo.commercesProches(centre, 5);
    expect(a5.map((r) => r.$1.nom), ['Maquis du Plateau', 'Chez Tanti']);
    expect(a5.first.$2, closeTo(0.56, 0.1));

    final a50 = await repo.commercesProches(centre, 50);
    expect(a50.map((r) => r.$1.nom), [
      'Maquis du Plateau',
      'Chez Tanti',
      'Grand-Bassam Grill',
    ]);
  });

  testWidgets('« Près de moi » : distances, rayon, filtres', (tester) async {
    ecranTelephone(tester);
    final banc = Banc();
    await preparer(banc.firestore);
    await banc.lancer(tester);

    await toucher(tester, find.widgetWithText(FilterChip, 'Près de moi'));
    expect(find.text('Maquis du Plateau'), findsOneWidget);
    expect(find.text('Chez Tanti'), findsOneWidget);
    expect(find.text('Grand-Bassam Grill'), findsNothing);
    expect(find.text('Pas Publié'), findsNothing);
    expect(find.textContaining('560 m'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Maquis du Plateau')).dy,
      lessThan(tester.getTopLeft(find.text('Chez Tanti')).dy),
    );

    // Rayon 50 km : le grill de Grand-Bassam apparaît.
    await toucher(tester, find.byTooltip('Rayon de recherche'));
    await toucher(tester, find.text('50 km').last);
    expect(find.text('Grand-Bassam Grill'), findsOneWidget);

    // Les filtres s'appliquent aussi.
    await toucher(tester, find.widgetWithText(FilterChip, 'Chrétien'));
    expect(find.text('Chez Tanti'), findsOneWidget);
    expect(find.text('Maquis du Plateau'), findsNothing);
  });

  testWidgets('localisation refusée : message clair', (tester) async {
    ecranTelephone(tester);
    final banc = Banc();
    banc.localisation.erreur = ErreurLocalisation.permissionRefusee;
    await preparer(banc.firestore);
    await banc.lancer(tester);
    await toucher(tester, find.widgetWithText(FilterChip, 'Près de moi'));
    expect(
      find.textContaining('n\'a pas accès à votre position'),
      findsOneWidget,
    );
  });

  testWidgets('vue carte : repères, puis ouverture d\'une fiche', (
    tester,
  ) async {
    ecranTelephone(tester);
    final banc = Banc();
    await preparer(banc.firestore);
    await banc.lancer(tester);
    await toucher(tester, find.byTooltip('Voir sur la carte'));
    expect(find.text('Repère Chez Tanti'), findsOneWidget);
    await toucher(tester, find.text('Repère Chez Tanti'));
    expect(find.text('Produits'), findsOneWidget);
    await toucher(tester, find.byType(BackButton));
    await toucher(tester, find.byTooltip('Voir la liste'));
    expect(find.text('Chez Tanti'), findsOneWidget);
  });
}
