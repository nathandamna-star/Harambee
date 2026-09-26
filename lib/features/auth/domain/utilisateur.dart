import 'package:cloud_firestore/cloud_firestore.dart';

import 'role.dart';

/// Profil stocké dans `users/{uid}`.
class Utilisateur {
  const Utilisateur({
    required this.uid,
    required this.nom,
    required this.email,
    required this.role,
    this.photoUrl,
    this.langue = 'fr',
    this.ville,
    this.pays,
    this.favoris = const [],
    this.createdAt,
  });

  final String uid;
  final String nom;
  final String email;
  final String? photoUrl;
  final Role role;
  final String langue;
  final String? ville;
  final String? pays;
  final List<String> favoris;
  final DateTime? createdAt;

  factory Utilisateur.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return Utilisateur(
      uid: doc.id,
      nom: d['nom'] as String? ?? '',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      role: Role.depuisTexte(d['role'] as String?),
      langue: d['langue'] as String? ?? 'fr',
      ville: d['ville'] as String?,
      pays: d['pays'] as String?,
      favoris: List<String>.from(d['favoris'] as List? ?? const []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
