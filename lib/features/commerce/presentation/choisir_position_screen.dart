import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../l10n/app_localizations.dart';

/// Placer précisément le commerce sur la carte : on touche la carte pour
/// déplacer le repère. Renvoie la position choisie, ou null.
class ChoisirPositionScreen extends StatefulWidget {
  const ChoisirPositionScreen({super.key, this.initiale});

  final GeoPoint? initiale;

  @override
  State<ChoisirPositionScreen> createState() => _ChoisirPositionScreenState();
}

class _ChoisirPositionScreenState extends State<ChoisirPositionScreen> {
  late LatLng? _position = widget.initiale == null
      ? null
      : LatLng(widget.initiale!.latitude, widget.initiale!.longitude);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.ajusterPosition)),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _position == null
                ? const CameraPosition(target: LatLng(20, -10), zoom: 2)
                : CameraPosition(target: _position!, zoom: 17),
            myLocationEnabled: true,
            mapToolbarEnabled: false,
            onTap: (p) => setState(() => _position = p),
            markers: {
              if (_position != null)
                Marker(
                  markerId: const MarkerId('commerce'),
                  position: _position!,
                  draggable: true,
                  onDragEnd: (p) => setState(() => _position = p),
                ),
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(l10n.ajusterPositionAide),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton(
                onPressed: _position == null
                    ? null
                    : () => Navigator.pop(
                        context,
                        GeoPoint(_position!.latitude, _position!.longitude),
                      ),
                child: Text(l10n.validerPosition),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
