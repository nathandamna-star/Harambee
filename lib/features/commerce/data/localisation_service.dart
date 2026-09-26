import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

enum ErreurLocalisation { serviceDesactive, permissionRefusee, inconnue }

class ExceptionLocalisation implements Exception {
  const ExceptionLocalisation(this.erreur);
  final ErreurLocalisation erreur;
}

/// Position actuelle du téléphone.
abstract interface class LocalisationService {
  /// Lève [ExceptionLocalisation] si la position n'est pas disponible.
  Future<GeoPoint> positionActuelle();
}

class LocalisationServiceNatif implements LocalisationService {
  @override
  Future<GeoPoint> positionActuelle() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ExceptionLocalisation(ErreurLocalisation.serviceDesactive);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const ExceptionLocalisation(ErreurLocalisation.permissionRefusee);
    }
    try {
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return GeoPoint(p.latitude, p.longitude);
    } catch (_) {
      throw const ExceptionLocalisation(ErreurLocalisation.inconnue);
    }
  }
}
