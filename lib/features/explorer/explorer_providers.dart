import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/avis.dart';
import '../../shared/models/commerce.dart';
import '../../shared/models/horaires.dart';
import '../../shared/models/produit.dart';
import '../../shared/services/lanceur.dart';
import '../auth/auth_providers.dart';
import 'data/explorer_repository.dart';
import 'data/filtres.dart';

/// Heure courante (remplaçable dans les tests).
final horlogeProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final lanceurProvider = Provider<Lanceur>((ref) => LanceurNatif());

final explorerRepositoryProvider = Provider<ExplorerRepository>(
  (ref) => ExplorerRepository(ref.watch(firestoreProvider)),
);

final filtresProvider = NotifierProvider<Filtres, FiltresExplorer>(Filtres.new);

class Filtres extends Notifier<FiltresExplorer> {
  @override
  FiltresExplorer build() => const FiltresExplorer();

  void definir(FiltresExplorer filtres) {
    state = filtres;
    ref.read(limiteProvider.notifier).reinitialiser();
  }
}

/// Nombre de résultats demandés (augmente avec « Voir plus »).
final limiteProvider = NotifierProvider<Limite, int>(Limite.new);

class Limite extends Notifier<int> {
  static const pas = 30;

  @override
  int build() => pas;

  void plus() => state += pas;
  void reinitialiser() => state = pas;
}

final resultatsExplorerProvider = StreamProvider<List<Commerce>>((ref) {
  final filtres = ref.watch(filtresProvider);
  final limite = ref.watch(limiteProvider);
  final maintenant = ref.watch(horlogeProvider);
  return ref
      .watch(explorerRepositoryProvider)
      .commercesPublies(filtres, limite: limite)
      .map(
        (liste) => filtres.ouvertMaintenant
            ? liste.where((c) => estOuvert(c.horaires, maintenant())).toList()
            : liste,
      );
});

final produitsPubliesProvider = StreamProvider.family<List<Produit>, String>(
  (ref, id) => ref.watch(explorerRepositoryProvider).produitsPublies(id),
);

final avisProvider = StreamProvider.family<List<Avis>, String>(
  (ref, id) => ref.watch(explorerRepositoryProvider).avis(id),
);

/// Identifiants des favoris de l'utilisateur connecté.
final favorisIdsProvider = Provider<List<String>>(
  (ref) => ref.watch(profilProvider).value?.favoris ?? const [],
);

final commercesFavorisProvider = FutureProvider<List<Commerce>>((ref) {
  final ids = ref.watch(favorisIdsProvider);
  if (ids.isEmpty) return const [];
  return ref.watch(explorerRepositoryProvider).commercesParIds(ids);
});
