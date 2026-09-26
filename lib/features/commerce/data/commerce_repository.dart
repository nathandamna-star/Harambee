import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';

import '../../../shared/models/commerce.dart';
import '../../../shared/models/produit.dart';
import 'photos_service.dart';

/// Photo d'une fiche : déjà en ligne ([url]) ou nouvelle ([octets]).
class PhotoFiche {
  const PhotoFiche.enLigne(String this.url) : octets = null;
  const PhotoFiche.nouvelle(Uint8List this.octets) : url = null;

  final String? url;
  final Uint8List? octets;
}

/// Lecture et écriture des commerces et de leurs produits par le pro.
class CommerceRepository {
  CommerceRepository({required this.firestore, required this.photos});

  final FirebaseFirestore firestore;
  final PhotosService photos;

  static const maxPhotosFiche = 6;

  CollectionReference<Map<String, dynamic>> get _commerces =>
      firestore.collection('commerces');

  CollectionReference<Map<String, dynamic>> _produits(String commerceId) =>
      _commerces.doc(commerceId).collection('produits');

  /// Commerces appartenant à [uid], y compris en vérification.
  Stream<List<Commerce>> commercesDuPro(String uid) => _commerces
      .where('proprietaire', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(Commerce.depuisFirestore).toList());

  Stream<Commerce?> commerce(String id) => _commerces
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Commerce.depuisFirestore(d) : null);

  /// Crée la fiche (« en vérification »), puis envoie les photos.
  /// La fiche doit exister avant l'envoi : les règles Storage vérifient
  /// que l'utilisateur en est le propriétaire.
  Future<String> creer(Commerce commerce, List<PhotoFiche> photosFiche) async {
    final ref = _commerces.doc();
    await ref.set(_avecGeohash(commerce).pourCreation()..['photos'] = []);
    final urls = await _envoyerPhotos(ref.id, photosFiche);
    if (urls.isNotEmpty) {
      await ref.update({'photos': urls});
    }
    return ref.id;
  }

  /// Met à jour la fiche. Les photos retirées sont supprimées du stockage.
  Future<void> modifier(Commerce commerce, List<PhotoFiche> photosFiche) async {
    final urls = await _envoyerPhotos(commerce.id, photosFiche);
    await _commerces
        .doc(commerce.id)
        .update(
          _avecGeohash(commerce.copyWith(photos: urls)).pourModification(),
        );
    for (final ancienne in commerce.photos) {
      if (!urls.contains(ancienne)) await photos.supprimer(ancienne);
    }
  }

  Future<List<String>> _envoyerPhotos(
    String commerceId,
    List<PhotoFiche> photosFiche,
  ) async {
    final urls = <String>[];
    for (final photo in photosFiche.take(maxPhotosFiche)) {
      urls.add(
        photo.url ??
            await photos.envoyerPhotoCommerce(commerceId, photo.octets!),
      );
    }
    return urls;
  }

  static Commerce _avecGeohash(Commerce c) {
    final geo = c.geo;
    if (geo == null) return c;
    // Attention : dart_geohash attend la longitude en premier.
    return c.copyWith(
      geohash: GeoHasher().encode(geo.longitude, geo.latitude, precision: 9),
    );
  }

  // ---------- Produits ----------

  Stream<List<Produit>> produits(String commerceId) =>
      _produits(commerceId)
          .orderBy('ordre')
          .snapshots()
          .map((s) => s.docs.map(Produit.depuisFirestore).toList());

  /// Ajoute ou met à jour un produit, avec sa photo éventuelle.
  Future<void> enregistrerProduit(
    String commerceId,
    Produit produit, {
    Uint8List? nouvellePhoto,
  }) async {
    final nouveau = produit.id.isEmpty;
    final ref = nouveau
        ? _produits(commerceId).doc()
        : _produits(commerceId).doc(produit.id);
    var p = produit.copyWith(id: ref.id);
    final anciennePhoto = produit.photoUrl;
    if (nouvellePhoto != null) {
      p = p.copyWith(
        photoUrl: await photos.envoyerPhotoProduit(
          commerceId,
          ref.id,
          nouvellePhoto,
        ),
      );
    }
    if (nouveau) {
      final dernier = await _produits(commerceId)
          .orderBy('ordre', descending: true)
          .limit(1)
          .get();
      final ordre = dernier.docs.isEmpty
          ? 0
          : ((dernier.docs.first.data()['ordre'] as num? ?? 0).toInt() + 1);
      await ref.set({
        ...p.copyWith(ordre: ordre).versFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update(p.versFirestore());
    }
    if (nouvellePhoto != null && anciennePhoto != null) {
      await photos.supprimer(anciennePhoto);
    }
  }

  Future<void> definirPublie(
    String commerceId,
    String produitId,
    bool publie,
  ) => _produits(commerceId)
      .doc(produitId)
      .update({'publie': publie, 'updatedAt': FieldValue.serverTimestamp()});

  Future<void> definirRupture(
    String commerceId,
    String produitId,
    bool enRupture,
  ) => _produits(commerceId).doc(produitId).update({
    'enRupture': enRupture,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> supprimerProduit(String commerceId, Produit produit) async {
    await _produits(commerceId).doc(produit.id).delete();
    if (produit.photoUrl != null) await photos.supprimer(produit.photoUrl!);
  }

  /// Enregistre le nouvel ordre d'affichage du catalogue.
  Future<void> reordonner(String commerceId, List<String> produitIds) async {
    final lot = firestore.batch();
    for (var i = 0; i < produitIds.length; i++) {
      lot.update(_produits(commerceId).doc(produitIds[i]), {'ordre': i});
    }
    await lot.commit();
  }
}
