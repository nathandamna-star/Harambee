import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shared/models/avis.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/geo.dart';
import '../../../shared/models/produit.dart';
import '../../../shared/models/recherche.dart';
import '../../../shared/models/signalement.dart';
import 'filtres.dart';

/// Lectures et écritures côté client : commerces publiés, produits visibles,
/// avis, favoris, signalements.
class ExplorerRepository {
  ExplorerRepository(this.firestore);

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _commerces =>
      firestore.collection('commerces');

  /// Commerces publiés correspondant aux filtres « serveur ».
  /// La recherche utilise `motsCles` (premier mot) ; le reste des mots et
  /// « ouvert maintenant » sont filtrés sur le téléphone.
  Stream<List<Commerce>> commercesPublies(
    FiltresExplorer f, {
    required int limite,
  }) {
    Query<Map<String, dynamic>> q = _commerces.where(
      'statut',
      isEqualTo: StatutCommerce.publie.valeur,
    );
    if (f.continent != null) {
      q = q.where('continent', isEqualTo: f.continent!.name);
    }
    if (f.categorie != null) {
      q = q.where('categorie', isEqualTo: f.categorie!.name);
    }
    if (f.africain) q = q.where('labelAfricain', isEqualTo: true);
    if (f.chretien) q = q.where('labelChretien', isEqualTo: true);
    final mots = motsNormalises(f.recherche);
    if (mots.isNotEmpty) {
      final mot = mots.first;
      q = q.where(
        'motsCles',
        arrayContains: mot.length > 15 ? mot.substring(0, 15) : mot,
      );
    }
    return q.limit(limite).snapshots().map((s) {
      final liste = s.docs
          .map(Commerce.depuisFirestore)
          .where((c) => correspondRecherche(f.recherche, [c.nom, c.ville]))
          .toList();
      liste.sort((a, b) {
        final note = b.noteMoyenne.compareTo(a.noteMoyenne);
        if (note != 0) return note;
        final nb = b.nbAvis.compareTo(a.nbAvis);
        return nb != 0 ? nb : a.nom.compareTo(b.nom);
      });
      return liste;
    });
  }

  /// Commerces publiés à moins de [rayonKm] de [centre], du plus proche au
  /// plus éloigné. Requête par zones geohash (index composite statut +
  /// geohash, voir firebase/firestore.indexes.json).
  Future<List<(Commerce, double)>> commercesProches(
    GeoPoint centre,
    double rayonKm,
  ) async {
    final requetes = zonesRecherche(centre, rayonKm).map(
      (zone) => _commerces
          .where('statut', isEqualTo: StatutCommerce.publie.valeur)
          .where('geohash', isGreaterThanOrEqualTo: zone)
          .where('geohash', isLessThan: '$zone~')
          .get(),
    );
    final vus = <String>{};
    final resultat = <(Commerce, double)>[];
    for (final s in await Future.wait(requetes)) {
      for (final doc in s.docs) {
        if (!vus.add(doc.id)) continue;
        final c = Commerce.depuisFirestore(doc);
        if (c.geo == null) continue;
        final d = distanceKm(centre, c.geo!);
        if (d <= rayonKm) resultat.add((c, d));
      }
    }
    return resultat..sort((a, b) => a.$2.compareTo(b.$2));
  }

  /// Produits visibles par les clients, dans l'ordre choisi par le commerçant.
  Stream<List<Produit>> produitsPublies(String commerceId) => _commerces
      .doc(commerceId)
      .collection('produits')
      .where('publie', isEqualTo: true)
      .snapshots()
      .map(
        (s) =>
            s.docs.map(Produit.depuisFirestore).toList()
              ..sort((a, b) => a.ordre.compareTo(b.ordre)),
      );

  Stream<List<Avis>> avis(String commerceId) => _commerces
      .doc(commerceId)
      .collection('avis')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Avis.depuisFirestore).toList());

  /// Crée ou met à jour l'avis de [uid] (un seul avis par personne).
  Future<void> enregistrerAvis(
    String commerceId, {
    required String uid,
    required String auteurNom,
    required int note,
    required String texte,
  }) async {
    final ref = _commerces.doc(commerceId).collection('avis').doc(uid);
    if ((await ref.get()).exists) {
      await ref.update({
        'note': note,
        'texte': texte.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.set(
        Avis(
          auteur: uid,
          auteurNom: auteurNom,
          note: note,
          texte: texte.trim(),
        ).pourCreation(),
      );
    }
  }

  Future<void> supprimerAvis(String commerceId, String uid) =>
      _commerces.doc(commerceId).collection('avis').doc(uid).delete();

  Future<void> definirFavori(String uid, String commerceId, bool favori) =>
      firestore.collection('users').doc(uid).update({
        'favoris': favori
            ? FieldValue.arrayUnion([commerceId])
            : FieldValue.arrayRemove([commerceId]),
      });

  /// Commerces publiés parmi [ids] (par lots de 30, limite de Firestore).
  Future<List<Commerce>> commercesParIds(List<String> ids) async {
    final resultat = <Commerce>[];
    for (var i = 0; i < ids.length; i += 30) {
      final lot = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final s = await _commerces
          .where(FieldPath.documentId, whereIn: lot)
          .where('statut', isEqualTo: StatutCommerce.publie.valeur)
          .get();
      resultat.addAll(s.docs.map(Commerce.depuisFirestore));
    }
    // Même ordre que la liste de favoris (le plus récent en premier).
    final rang = {for (var i = 0; i < ids.length; i++) ids[i]: i};
    return resultat..sort((a, b) => rang[b.id]!.compareTo(rang[a.id]!));
  }

  Future<void> signaler(Signalement signalement) =>
      firestore.collection('signalements').add(signalement.pourCreation());
}
