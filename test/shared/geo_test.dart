import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/shared/models/geo.dart';

void main() {
  const paris = GeoPoint(48.8566, 2.3522);
  const lyon = GeoPoint(45.7640, 4.8357);
  const abidjan = GeoPoint(5.32, -4.02);

  test('distance Paris – Lyon ≈ 392 km', () {
    expect(distanceKm(paris, lyon), closeTo(392, 3));
    expect(distanceKm(paris, paris), 0);
  });

  test('précision : zones assez grandes pour le rayon', () {
    expect(precisionPourRayon(2, 5), 5);
    expect(precisionPourRayon(10, 5), 4);
    expect(precisionPourRayon(50, 5), 3);
    // Plus au nord, les zones sont plus étroites.
    expect(precisionPourRayon(4, 60), 4);
  });

  test('9 zones à interroger autour du centre', () {
    // 2 km : zones de ~4,9 km (5 caractères) ; 5 km : zones plus grandes.
    final zones = zonesRecherche(abidjan, 2);
    expect(zones, hasLength(9));
    expect(zones.every((z) => z.length == 5), isTrue);
    expect(zonesRecherche(abidjan, 5).every((z) => z.length == 4), isTrue);
  });

  test('affichage des distances', () {
    expect(formaterDistance(0.853, 'fr'), '850 m');
    expect(formaterDistance(1.24, 'fr'), '1,2 km');
    expect(formaterDistance(1.24, 'en'), '1.2 km');
    expect(formaterDistance(12.4, 'fr'), '12 km');
  });
}
