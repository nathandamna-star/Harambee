import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Signalement d'un contenu : `signalements/{id}`.
class Signalement {
  const Signalement({
    required this.auteur,
    required this.cible,
    required this.cibleId,
    required this.motif,
    this.id = '',
    this.traite = false,
    this.createdAt,
  });

  final String id;
  final String auteur;
  final CibleSignalement cible;
  final String cibleId;
  final String motif;
  final bool traite;
  final DateTime? createdAt;

  factory Signalement.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return Signalement(
      id: doc.id,
      auteur: d['auteur'] as String? ?? '',
      cible: enumDepuis(
        CibleSignalement.values,
        d['cible'] as String?,
        CibleSignalement.commerce,
      ),
      cibleId: d['cibleId'] as String? ?? '',
      motif: d['motif'] as String? ?? '',
      traite: d['traite'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> pourCreation() => {
    'auteur': auteur,
    'cible': cible.name,
    'cibleId': cibleId,
    'motif': motif,
    'traite': false,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
