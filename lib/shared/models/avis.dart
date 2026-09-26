import 'package:cloud_firestore/cloud_firestore.dart';

/// Avis : `commerces/{commerceId}/avis/{uid}`.
/// L'identifiant du document est l'uid de l'auteur : un seul avis par personne.
class Avis {
  const Avis({
    required this.auteur,
    required this.note,
    this.auteurNom = '',
    this.texte = '',
    this.createdAt,
  }) : assert(note >= 1 && note <= 5);

  final String auteur;
  final String auteurNom;
  final int note;
  final String texte;
  final DateTime? createdAt;

  factory Avis.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Avis(
      auteur: doc.id,
      auteurNom: d['auteurNom'] as String? ?? '',
      note: ((d['note'] as num? ?? 5).toInt()).clamp(1, 5),
      texte: d['texte'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> pourCreation() => {
    'auteur': auteur,
    'auteurNom': auteurNom,
    'note': note,
    'texte': texte,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
