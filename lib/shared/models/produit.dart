import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Produit du catalogue : `commerces/{commerceId}/produits/{produitId}`.
class Produit {
  const Produit({
    required this.id,
    required this.nom,
    required this.prix,
    required this.devise,
    this.description = '',
    this.photoUrl,
    this.publie = true,
    this.enRupture = false,
    this.ordre = 0,
    this.createdAt,
  });

  final String id;
  final String nom;
  final String description;
  final String? photoUrl;

  /// Prix dans la [devise] du commerce (ex. 8.5 pour 8,50 €).
  final num prix;
  final Devise devise;
  final bool publie;
  final bool enRupture;
  final int ordre;
  final DateTime? createdAt;

  factory Produit.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Produit(
      id: doc.id,
      nom: d['nom'] as String? ?? '',
      description: d['description'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      prix: d['prix'] as num? ?? 0,
      devise: enumDepuis(Devise.values, d['devise'] as String?, Devise.EUR),
      publie: d['publie'] as bool? ?? false,
      enRupture: d['enRupture'] as bool? ?? false,
      ordre: (d['ordre'] as num? ?? 0).toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> versFirestore() => {
    'nom': nom,
    'description': description,
    'photoUrl': photoUrl,
    'prix': prix,
    'devise': devise.name,
    'publie': publie,
    'enRupture': enRupture,
    'ordre': ordre,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
