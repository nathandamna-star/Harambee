import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../shared/models/commerce.dart';
import '../explorer_providers.dart';

/// Construit la carte des résultats. Remplaçable dans les tests, où la vraie
/// carte Google (vue native du téléphone) n'est pas disponible.
typedef ConstructeurCarte = Widget Function({
  required List<ResultatExplorer> resultats,
  required RechercheProche? proche,
  required void Function(Commerce) onOuvrir,
});

final constructeurCarteProvider = Provider<ConstructeurCarte>(
  (ref) =>
      ({required resultats, required proche, required onOuvrir}) =>
          CarteGoogleResultats(
            resultats: resultats,
            proche: proche,
            onOuvrir: onOuvrir,
          ),
);

/// Vue carte d'Explorer : un repère par commerce ; toucher la bulle ouvre la
/// fiche.
class CarteGoogleResultats extends StatefulWidget {
  const CarteGoogleResultats({
    super.key,
    required this.resultats,
    required this.proche,
    required this.onOuvrir,
  });

  final List<ResultatExplorer> resultats;
  final RechercheProche? proche;
  final void Function(Commerce) onOuvrir;

  @override
  State<CarteGoogleResultats> createState() => _CarteGoogleResultatsState();
}

class _CarteGoogleResultatsState extends State<CarteGoogleResultats> {
  GoogleMapController? _controleur;

  // Vue d'ensemble Europe – Afrique – Amériques quand rien n'est localisé.
  static const _vueMonde = CameraPosition(target: LatLng(20, -10), zoom: 1.8);

  List<Commerce> get _localises => [
    for (final r in widget.resultats)
      if (r.commerce.geo != null) r.commerce,
  ];

  @override
  void didUpdateWidget(covariant CarteGoogleResultats ancien) {
    super.didUpdateWidget(ancien);
    if (ancien.resultats != widget.resultats ||
        ancien.proche != widget.proche) {
      _cadrer();
    }
  }

  /// Cadre la carte sur le rayon de recherche, ou sur tous les repères.
  Future<void> _cadrer() async {
    final c = _controleur;
    if (c == null) return;
    final proche = widget.proche;
    if (proche != null) {
      await c.animateCamera(
        CameraUpdate.newLatLngBounds(_limitesRayon(proche), 32),
      );
      return;
    }
    final points = [for (final m in _localises) _latLng(m.geo!)];
    if (points.isEmpty) return;
    if (points.length == 1) {
      await c.animateCamera(CameraUpdate.newLatLngZoom(points.first, 14));
      return;
    }
    await c.animateCamera(CameraUpdate.newLatLngBounds(_limites(points), 48));
  }

  static LatLng _latLng(GeoPoint g) => LatLng(g.latitude, g.longitude);

  static LatLngBounds _limites(List<LatLng> points) => LatLngBounds(
    southwest: LatLng(
      points.map((p) => p.latitude).reduce(min),
      points.map((p) => p.longitude).reduce(min),
    ),
    northeast: LatLng(
      points.map((p) => p.latitude).reduce(max),
      points.map((p) => p.longitude).reduce(max),
    ),
  );

  static LatLngBounds _limitesRayon(RechercheProche p) {
    final dLat = p.rayonKm / 111.0;
    final dLon =
        p.rayonKm / (111.0 * cos(p.centre.latitude * pi / 180).clamp(0.1, 1));
    return LatLngBounds(
      southwest: LatLng(p.centre.latitude - dLat, p.centre.longitude - dLon),
      northeast: LatLng(p.centre.latitude + dLat, p.centre.longitude + dLon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proche = widget.proche;
    return GoogleMap(
      initialCameraPosition: proche == null
          ? _vueMonde
          : CameraPosition(target: _latLng(proche.centre), zoom: 12),
      myLocationEnabled: proche != null,
      myLocationButtonEnabled: proche != null,
      mapToolbarEnabled: false,
      onMapCreated: (c) {
        _controleur = c;
        _cadrer();
      },
      markers: {
        for (final m in _localises)
          Marker(
            markerId: MarkerId(m.id),
            position: _latLng(m.geo!),
            infoWindow: InfoWindow(
              title: m.nom,
              snippet: m.ville,
              onTap: () => widget.onOuvrir(m),
            ),
          ),
      },
      circles: {
        if (proche != null)
          Circle(
            circleId: const CircleId('rayon'),
            center: _latLng(proche.centre),
            radius: proche.rayonKm * 1000,
            strokeWidth: 1,
            strokeColor: Theme.of(context).colorScheme.primary,
            fillColor: Theme.of(context).colorScheme.primary
                .withValues(alpha: 0.06),
          ),
      },
    );
  }
}
