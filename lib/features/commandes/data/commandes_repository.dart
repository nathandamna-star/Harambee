import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../shared/models/commande.dart';

/// Erreur renvoyée par la Cloud Function `creerCommande`.
class ErreurCommande implements Exception {
  const ErreurCommande(this.code, {this.manque});

  /// Code du serveur : minimum-non-atteint, produit-indisponible, hors-zone…
  final String code;

  /// Montant manquant pour le minimum de commande.
  final num? manque;
}

/// Données envoyées au serveur pour créer une commande. Aucun prix : le
/// serveur les relit dans le catalogue.
class DemandeCommande {
  const DemandeCommande({
    required this.commerceId,
    required this.lignes,
    required this.mode,
    required this.methode,
    required this.telephone,
    this.adresseTexte,
    this.adresseGeo,
    this.instructions,
  });

  final String commerceId;
  final Map<String, int> lignes;
  final ModeCommande mode;
  final MethodePaiement methode;
  final String telephone;
  final String? adresseTexte;
  final GeoPoint? adresseGeo;
  final String? instructions;

  Map<String, dynamic> versJson() => {
    'commerceId': commerceId,
    'lignes': [
      for (final e in lignes.entries) {'produitId': e.key, 'quantite': e.value},
    ],
    'mode': mode.name,
    'methode': methode.name,
    'telephone': telephone,
    if (mode == ModeCommande.livraison)
      'adresse': {
        'texte': adresseTexte ?? '',
        'latitude': adresseGeo?.latitude,
        'longitude': adresseGeo?.longitude,
        'instructions': instructions ?? '',
      },
  };
}

/// Appel à la fonction serveur (remplaçable dans les tests).
abstract interface class FonctionsCommande {
  /// Renvoie l'identifiant de la commande créée, ou lève [ErreurCommande].
  Future<String> creer(DemandeCommande demande);
}

class FonctionsCommandeFirebase implements FonctionsCommande {
  FonctionsCommandeFirebase(this.fonctions);

  final FirebaseFunctions fonctions;

  @override
  Future<String> creer(DemandeCommande demande) async {
    try {
      final r = await fonctions
          .httpsCallable('creerCommande')
          .call<Map<String, dynamic>>(demande.versJson());
      return r.data['commandeId'] as String;
    } on FirebaseFunctionsException catch (e) {
      final details = e.details;
      // Le serveur place le code (minimum-non-atteint, hors-zone…) dans
      // details.code ; le message n'est qu'un repli.
      final code = details is Map ? details['code'] as String? : null;
      throw ErreurCommande(switch (e.code) {
        'failed-precondition' ||
        'invalid-argument' ||
        'not-found' => code ?? e.message ?? 'inconnue',
        'unavailable' || 'deadline-exceeded' => 'reseau',
        _ => 'inconnue',
      }, manque: details is Map ? details['manque'] as num? : null);
    }
  }
}

/// Lecture des commandes et changements de statut (client ou commerçant).
class CommandesRepository {
  CommandesRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _commandes =>
      firestore.collection('commandes');

  Stream<List<Commande>> _liste(Query<Map<String, dynamic>> q) =>
      q.snapshots().map((s) {
        final liste = s.docs.map(Commande.depuisFirestore).toList();
        final zero = DateTime.fromMillisecondsSinceEpoch(0);
        return liste..sort(
          (a, b) => (b.createdAt ?? zero).compareTo(a.createdAt ?? zero),
        );
      });

  Stream<List<Commande>> commandesClient(String uid) =>
      _liste(_commandes.where('clientId', isEqualTo: uid));

  Stream<List<Commande>> commandesPro(String uid) =>
      _liste(_commandes.where('proId', isEqualTo: uid));

  Stream<Commande?> commande(String id) => _commandes
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Commande.depuisFirestore(d) : null);

  /// Nouveau statut, ajouté à l'historique (règles : seul le commerce fait
  /// avancer la commande ; le client peut seulement annuler une « nouvelle »).
  Future<void> changerStatut(
    String commandeId,
    StatutCommande statut, {
    String? motif,
  }) => _commandes.doc(commandeId).update({
    'statut': statut.valeur,
    'historique': FieldValue.arrayUnion([
      {'statut': statut.valeur, 'date': Timestamp.now()},
    ]),
    'updatedAt': FieldValue.serverTimestamp(),
    'motifRefus': ?motif,
  });
}
