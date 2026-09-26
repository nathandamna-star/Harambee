import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/commande.dart';
import '../../shared/models/commerce.dart';
import '../../shared/models/produit.dart';
import '../../shared/models/tarifs.dart';
import '../auth/auth_providers.dart';
import 'data/commandes_repository.dart';
import 'data/panier.dart';

final fonctionsCommandeProvider = Provider<FonctionsCommande>(
  (ref) => FonctionsCommandeFirebase(
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  ),
);

final commandesRepositoryProvider = Provider<CommandesRepository>(
  (ref) => CommandesRepository(ref.watch(firestoreProvider)),
);

final tarifsProvider = StreamProvider<Tarifs>(
  (ref) => ref
      .watch(firestoreProvider)
      .doc('parametres/tarifs')
      .snapshots()
      .map((d) => Tarifs.depuis(d.data())),
);

/// Paniers en cours, un par commerce.
final paniersProvider = NotifierProvider<Paniers, Map<String, Panier>>(
  Paniers.new,
);

class Paniers extends Notifier<Map<String, Panier>> {
  @override
  Map<String, Panier> build() => {};

  void definir(Commerce commerce, Produit produit, int quantite) {
    final actuel = state[commerce.id] ?? Panier(commerce: commerce);
    final nouveau = Panier(
      commerce: commerce,
      lignes: actuel.lignes,
    ).avec(produit, quantite);
    state = {...state, commerce.id: nouveau};
  }

  void vider(String commerceId) => state = {...state}..remove(commerceId);
}

final mesCommandesProvider = StreamProvider<List<Commande>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(commandesRepositoryProvider).commandesClient(uid);
});

final commandesProProvider = StreamProvider<List<Commande>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(commandesRepositoryProvider).commandesPro(uid);
});

final commandeProvider = StreamProvider.family<Commande?, String>(
  (ref, id) => ref.watch(commandesRepositoryProvider).commande(id),
);

/// Nouvelles commandes à traiter par le commerçant.
final nbNouvellesCommandesProvider = Provider<int>(
  (ref) => (ref.watch(commandesProProvider).value ?? const [])
      .where((c) => c.statut == StatutCommande.nouvelle)
      .length,
);
