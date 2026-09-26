import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/signalement.dart';

/// Vérification des commerces et modération, réservées aux administrateurs
/// (les règles Firestore le garantissent côté serveur).
class AdminRepository {
  AdminRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _commerces =>
      firestore.collection('commerces');

  /// Commerces d'un statut donné. En attente : les plus anciens d'abord
  /// (file d'attente) ; sinon les plus récents d'abord.
  Stream<List<Commerce>> commercesParStatut(StatutCommerce statut) =>
      _commerces.where('statut', isEqualTo: statut.valeur).snapshots().map((s) {
        final liste = s.docs.map(Commerce.depuisFirestore).toList();
        final zero = DateTime.fromMillisecondsSinceEpoch(0);
        liste.sort(
          (a, b) => (a.createdAt ?? zero).compareTo(b.createdAt ?? zero),
        );
        return statut == StatutCommerce.enVerification
            ? liste
            : liste.reversed.toList();
      });

  /// Publie la fiche avec les labels confirmés par l'administrateur.
  Future<void> publier(
    String commerceId, {
    required bool labelAfricain,
    required bool labelChretien,
  }) => _commerces.doc(commerceId).update({
    'statut': StatutCommerce.publie.valeur,
    'labelAfricain': labelAfricain,
    'labelChretien': labelChretien,
    'motifRefus': FieldValue.delete(),
    'verifieLe': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  /// Modifie les labels d'une fiche déjà publiée.
  Future<void> definirLabels(
    String commerceId, {
    required bool labelAfricain,
    required bool labelChretien,
  }) => _commerces.doc(commerceId).update({
    'labelAfricain': labelAfricain,
    'labelChretien': labelChretien,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  /// Refuse une fiche en attente ou suspend une fiche publiée.
  /// Le motif est affiché au commerçant dans son espace.
  Future<void> suspendre(String commerceId, String motif) =>
      _commerces.doc(commerceId).update({
        'statut': StatutCommerce.suspendu.valeur,
        'motifRefus': motif.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Stream<List<Signalement>> signalementsATraiter() => firestore
      .collection('signalements')
      .where('traite', isEqualTo: false)
      .snapshots()
      .map((s) {
        final liste = s.docs.map(Signalement.depuisFirestore).toList();
        final zero = DateTime.fromMillisecondsSinceEpoch(0);
        liste.sort(
          (a, b) => (b.createdAt ?? zero).compareTo(a.createdAt ?? zero),
        );
        return liste;
      });

  Future<void> marquerTraite(String signalementId) => firestore
      .collection('signalements')
      .doc(signalementId)
      .update({'traite': true, 'traiteLe': FieldValue.serverTimestamp()});
}
