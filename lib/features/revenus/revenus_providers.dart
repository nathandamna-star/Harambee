import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/commande.dart';
import '../auth/auth_providers.dart';
import 'data/partage.dart';

final partageFichierProvider = Provider<PartageFichier>(
  (ref) => PartageNatif(),
);

/// Toutes les commandes d'une année (administrateurs seulement).
final commandesAnneeProvider = StreamProvider.family<List<Commande>, int>(
  (ref, annee) => ref
      .watch(firestoreProvider)
      .collection('commandes')
      .where(
        'createdAt',
        isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(annee)),
      )
      .where('createdAt', isLessThan: Timestamp.fromDate(DateTime(annee + 1)))
      .snapshots()
      .map((s) => s.docs.map(Commande.depuisFirestore).toList()),
);
