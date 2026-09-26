import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

/// Choix d'une photo sur le téléphone, déjà réduite et compressée
/// (utile avec une connexion lente).
abstract interface class SelecteurPhoto {
  /// Renvoie les octets JPEG de la photo, ou null si l'utilisateur annule.
  Future<Uint8List?> choisir({required bool camera});
}

class SelecteurPhotoNatif implements SelecteurPhoto {
  final _picker = ImagePicker();

  @override
  Future<Uint8List?> choisir({required bool camera}) async {
    final fichier = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 80,
    );
    return fichier?.readAsBytes();
  }
}

/// Envoi des photos dans Firebase Storage.
class PhotosService {
  PhotosService(this.storage);

  final FirebaseStorage storage;
  static const _uuid = Uuid();

  Future<String> envoyerPhotoCommerce(String commerceId, Uint8List octets) =>
      _envoyer('commerces/$commerceId/photos/${_uuid.v4()}.jpg', octets);

  Future<String> envoyerPhotoProduit(
    String commerceId,
    String produitId,
    Uint8List octets,
  ) => _envoyer(
    'commerces/$commerceId/produits/$produitId-${_uuid.v4()}.jpg',
    octets,
  );

  /// Supprime une photo à partir de son URL (sans erreur si elle n'existe plus).
  Future<void> supprimer(String url) async {
    try {
      await storage.refFromURL(url).delete();
    } catch (_) {
      // Photo déjà supprimée ou URL externe : rien à faire.
    }
  }

  Future<String> _envoyer(String chemin, Uint8List octets) async {
    final ref = storage.ref(chemin);
    await ref.putData(octets, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
