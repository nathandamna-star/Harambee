import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/avis.dart';
import '../../shared/models/commerce.dart';
import '../../shared/models/horaires.dart';
import '../../shared/models/produit.dart';
import '../../shared/models/recherche.dart';
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

/// Un commerce dans les résultats, avec sa distance en mode « Près de moi ».
typedef ResultatExplorer = ({Commerce commerce, double? distanceKm});

/// Recherche « près de moi » : point de départ et rayon.
class RechercheProche {
  const RechercheProche(this.centre, this.rayonKm);

  final GeoPoint centre;
  final double rayonKm;

  static const rayons = [2.0, 5.0, 10.0, 25.0, 50.0];
  static const rayonParDefaut = 10.0;
}

final rechercheProcheProvider =
    NotifierProvider<RechercheProcheNotifier, RechercheProche?>(
      RechercheProcheNotifier.new,
    );

class RechercheProcheNotifier extends Notifier<RechercheProche?> {
  @override
  RechercheProche? build() => null;

  void activer(GeoPoint centre) => state = RechercheProche(
    centre,
    state?.rayonKm ?? RechercheProche.rayonParDefaut,
  );

  void definirRayon(double rayonKm) {
    if (state != null) state = RechercheProche(state!.centre, rayonKm);
  }

  void desactiver() => state = null;
}

/// Vue carte (true) ou liste (false).
final vueCarteProvider = NotifierProvider<VueCarte, bool>(VueCarte.new);

class VueCarte extends Notifier<bool> {
  @override
  bool build() => false;

  void basculer() => state = !state;
}

/// Filtres appliqués sur le téléphone (mode « Près de moi »).
bool correspondFiltres(FiltresExplorer f, Commerce c, DateTime maintenant) =>
    (f.continent == null || c.continent == f.continent) &&
    (f.categorie == null || c.categorie == f.categorie) &&
    (!f.africain || c.labelAfricain) &&
    (!f.chretien || c.labelChretien) &&
    (!f.ouvertMaintenant || estOuvert(c.horaires, maintenant)) &&
    correspondRecherche(f.recherche, [c.nom, c.ville]);

final resultatsExplorerProvider = StreamProvider<List<ResultatExplorer>>((ref) {
  final filtres = ref.watch(filtresProvider);
  final limite = ref.watch(limiteProvider);
  final maintenant = ref.watch(horlogeProvider);
  final proche = ref.watch(rechercheProcheProvider);
  final repo = ref.watch(explorerRepositoryProvider);

  if (proche != null) {
    return Stream.fromFuture(
      repo.commercesProches(proche.centre, proche.rayonKm),
    ).map(
      (liste) => [
        for (final (c, d) in liste)
          if (correspondFiltres(filtres, c, maintenant()))
            (commerce: c, distanceKm: d),
      ],
    );
  }
  return repo
      .commercesPublies(filtres, limite: limite)
      .map(
        (liste) => [
          for (final c in liste)
            if (!filtres.ouvertMaintenant ||
                estOuvert(c.horaires, maintenant()))
              (commerce: c, distanceKm: null),
        ],
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
