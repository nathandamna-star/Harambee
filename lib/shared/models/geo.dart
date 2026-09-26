/// Calculs géographiques pour la recherche « près de moi ».
///
/// Principe : chaque commerce a un `geohash` (code dont les premiers
/// caractères désignent une zone). Pour chercher dans un rayon, on interroge
/// la zone du point de départ et ses 8 voisines, à une précision où une zone
/// est au moins aussi grande que le rayon ; puis on calcule la distance exacte.
library;

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';

const _rayonTerreKm = 6371.0;

/// Distance à vol d'oiseau (formule de haversine), en kilomètres.
double distanceKm(GeoPoint a, GeoPoint b) {
  double rad(double deg) => deg * pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLon = rad(b.longitude - a.longitude);
  final h =
      pow(sin(dLat / 2), 2) +
      cos(rad(a.latitude)) * cos(rad(b.latitude)) * pow(sin(dLon / 2), 2);
  return 2 * _rayonTerreKm * asin(sqrt(h));
}

/// Taille (largeur à l'équateur, hauteur) d'une zone geohash, en km.
const _taillesZones = <int, (double, double)>{
  1: (5000, 5000),
  2: (1250, 625),
  3: (156, 156),
  4: (39.1, 19.5),
  5: (4.89, 4.89),
  6: (1.22, 0.61),
};

/// Précision la plus fine dont les zones couvrent au moins [rayonKm]
/// dans chaque direction, à la latitude donnée.
int precisionPourRayon(double rayonKm, double latitude) {
  final facteur = cos(latitude.abs() * pi / 180).clamp(0.1, 1.0);
  for (var p = 6; p >= 1; p--) {
    final (largeur, hauteur) = _taillesZones[p]!;
    if (min(largeur * facteur, hauteur) >= rayonKm) return p;
  }
  return 1;
}

/// Préfixes geohash à interroger : la zone du centre et ses voisines.
List<String> zonesRecherche(GeoPoint centre, double rayonKm) {
  final hasher = GeoHasher();
  final zone = hasher.encode(
    centre.longitude,
    centre.latitude,
    precision: precisionPourRayon(rayonKm, centre.latitude),
  );
  return hasher.neighbors(zone).values.toSet().toList()..sort();
}

/// « 850 m », « 1,2 km », « 12 km ».
String formaterDistance(double km, String locale) {
  if (km < 1) return '${(km * 100).round() * 10} m';
  if (km < 10) {
    final texte = km.toStringAsFixed(1);
    return '${locale.startsWith('en') ? texte : texte.replaceAll('.', ',')} km';
  }
  return '${km.round()} km';
}
