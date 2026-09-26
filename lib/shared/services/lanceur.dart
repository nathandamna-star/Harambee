import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre les apps du téléphone : appel, cartes pour l'itinéraire.
abstract interface class Lanceur {
  Future<bool> appeler(String telephone);
  Future<bool> itineraire({GeoPoint? geo, required String adresse});

  /// Ouvre une page web dans le navigateur.
  Future<bool> ouvrir(Uri url);
}

class LanceurNatif implements Lanceur {
  @override
  Future<bool> ouvrir(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);

  @override
  Future<bool> appeler(String telephone) => launchUrl(
    Uri(scheme: 'tel', path: telephone.replaceAll(RegExp(r'[^0-9+]'), '')),
  );

  @override
  Future<bool> itineraire({GeoPoint? geo, required String adresse}) {
    final destination = geo == null
        ? adresse
        : '${geo.latitude},${geo.longitude}';
    // Plans sur iPhone, Google Maps ailleurs (ouvre l'app si elle est installée).
    final uri = defaultTargetPlatform == TargetPlatform.iOS
        ? Uri.https('maps.apple.com', '/', {'daddr': destination})
        : Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            'destination': destination,
          });
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
