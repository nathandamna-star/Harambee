import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../commerce/commerce_providers.dart';
import '../../commerce/data/localisation_service.dart';
import '../../commerce/presentation/libelles.dart';
import '../data/filtres.dart';
import '../explorer_providers.dart';
import 'carte_commerce.dart';
import 'carte_resultats.dart';

class ExplorerScreen extends ConsumerStatefulWidget {
  const ExplorerScreen({super.key});

  @override
  ConsumerState<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends ConsumerState<ExplorerScreen> {
  late final _recherche = TextEditingController(
    text: ref.read(filtresProvider).recherche,
  );

  @override
  void dispose() {
    _recherche.dispose();
    super.dispose();
  }

  bool _localisationEnCours = false;

  /// Active « Près de moi » : demande la position du téléphone.
  Future<void> _presDeMoi(bool activer) async {
    final notifier = ref.read(rechercheProcheProvider.notifier);
    if (!activer) {
      notifier.desactiver();
      return;
    }
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _localisationEnCours = true);
    try {
      notifier.activer(
        await ref.read(localisationServiceProvider).positionActuelle(),
      );
    } on ExceptionLocalisation catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(switch (e.erreur) {
              ErreurLocalisation.serviceDesactive =>
                l10n.localisationDesactivee,
              ErreurLocalisation.permissionRefusee => l10n.localisationRefusee,
              ErreurLocalisation.inconnue => l10n.localisationIndisponible,
            }),
          ),
        );
    } finally {
      if (mounted) setState(() => _localisationEnCours = false);
    }
  }

  void _rechercher(String texte) {
    final f = ref.read(filtresProvider);
    ref.read(filtresProvider.notifier).definir(f.copyWith(recherche: texte));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filtres = ref.watch(filtresProvider);
    final resultats = ref.watch(resultatsExplorerProvider);
    final limite = ref.watch(limiteProvider);
    final proche = ref.watch(rechercheProcheProvider);
    final vueCarte = ref.watch(vueCarteProvider);
    void ouvrir(String id) => context.push(Routes.commerceExplorer(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: vueCarte ? l10n.vueListe : l10n.vueCarte,
            icon: Icon(vueCarte ? Icons.view_list : Icons.map_outlined),
            onPressed: () => ref.read(vueCarteProvider.notifier).basculer(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _recherche,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _rechercher,
                    decoration: InputDecoration(
                      hintText: l10n.rechercherIndice,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: filtres.recherche.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.effacerRecherche,
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _recherche.clear();
                                _rechercher('');
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Badge(
                  isLabelVisible: filtres.nbActifs > 0,
                  label: Text('${filtres.nbActifs}'),
                  child: IconButton.outlined(
                    tooltip: l10n.filtres,
                    icon: const Icon(Icons.tune),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => const _FeuilleFiltres(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: _localisationEnCours
                        ? SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: l10n.chargement,
                            ),
                          )
                        : const Icon(Icons.near_me_outlined, size: 18),
                    label: Text(l10n.presDeMoi),
                    selected: proche != null,
                    onSelected: _localisationEnCours ? null : _presDeMoi,
                  ),
                ),
                if (proche != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: PopupMenuButton<double>(
                      tooltip: l10n.rayon,
                      initialValue: proche.rayonKm,
                      onSelected: (r) => ref
                          .read(rechercheProcheProvider.notifier)
                          .definirRayon(r),
                      itemBuilder: (_) => [
                        for (final r in RechercheProche.rayons)
                          PopupMenuItem(
                            value: r,
                            child: Text(l10n.rayonKm(r.round())),
                          ),
                      ],
                      child: Chip(
                        label: Text(l10n.rayonKm(proche.rayonKm.round())),
                        deleteIcon: const Icon(Icons.arrow_drop_down),
                        onDeleted: null,
                        avatar: const Icon(Icons.radar, size: 18),
                      ),
                    ),
                  ),
                _Raccourci(
                  libelle: l10n.labelAfricain,
                  actif: filtres.africain,
                  onChanged: (v) => ref
                      .read(filtresProvider.notifier)
                      .definir(filtres.copyWith(africain: v)),
                ),
                _Raccourci(
                  libelle: l10n.labelChretien,
                  actif: filtres.chretien,
                  onChanged: (v) => ref
                      .read(filtresProvider.notifier)
                      .definir(filtres.copyWith(chretien: v)),
                ),
                _Raccourci(
                  libelle: l10n.ouvertMaintenant,
                  actif: filtres.ouvertMaintenant,
                  onChanged: (v) => ref
                      .read(filtresProvider.notifier)
                      .definir(filtres.copyWith(ouvertMaintenant: v)),
                ),
                for (final c in Categorie.values)
                  _Raccourci(
                    libelle: l10n.categorie(c),
                    actif: filtres.categorie == c,
                    onChanged: (v) => ref
                        .read(filtresProvider.notifier)
                        .definir(
                          filtres.copyWith(categorie: () => v ? c : null),
                        ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: resultats.when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  semanticsLabel: l10n.chargement,
                ),
              ),
              error: (_, _) => EtatVide(
                icone: Icons.wifi_off,
                titre: l10n.erreurReseau,
                texte: '',
              ),
              data: (liste) => vueCarte
                  ? ref.watch(constructeurCarteProvider)(
                      resultats: liste,
                      proche: proche,
                      onOuvrir: (c) => ouvrir(c.id),
                    )
                  : liste.isEmpty
                  ? EtatVide(
                      icone: proche != null
                          ? Icons.near_me_disabled_outlined
                          : Icons.storefront_outlined,
                      titre: proche != null
                          ? l10n.aucunCommerceProche(proche.rayonKm.round())
                          : filtres == const FiltresExplorer()
                          ? l10n.explorerVideTitre
                          : l10n.aucunResultatTitre,
                      texte: proche != null
                          ? l10n.aucunCommerceProcheAide
                          : filtres == const FiltresExplorer()
                          ? l10n.explorerVideTexte
                          : l10n.aucunResultatTexte,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount:
                          liste.length +
                          (proche == null && liste.length >= limite ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => i == liste.length
                          ? OutlinedButton(
                              onPressed: () =>
                                  ref.read(limiteProvider.notifier).plus(),
                              child: Text(l10n.voirPlus),
                            )
                          : CarteCommerce(
                              commerce: liste[i].commerce,
                              distanceKm: liste[i].distanceKm,
                              onTap: () => ouvrir(liste[i].commerce.id),
                            ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Raccourci extends StatelessWidget {
  const _Raccourci({
    required this.libelle,
    required this.actif,
    required this.onChanged,
  });

  final String libelle;
  final bool actif;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: FilterChip(
      label: Text(libelle),
      selected: actif,
      onSelected: onChanged,
    ),
  );
}

/// Tous les filtres, dans une feuille qui monte du bas de l'écran.
class _FeuilleFiltres extends ConsumerWidget {
  const _FeuilleFiltres();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final f = ref.watch(filtresProvider);
    void definir(FiltresExplorer n) =>
        ref.read(filtresProvider.notifier).definir(n);

    final continents = {
      Continent.europe: l10n.continentEurope,
      Continent.afrique: l10n.continentAfrique,
      Continent.amerique: l10n.continentAmerique,
    };

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filtres, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text(l10n.continent, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.tous),
                  selected: f.continent == null,
                  onSelected: (_) => definir(f.copyWith(continent: () => null)),
                ),
                for (final e in continents.entries)
                  ChoiceChip(
                    label: Text(e.value),
                    selected: f.continent == e.key,
                    onSelected: (_) =>
                        definir(f.copyWith(continent: () => e.key)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(l10n.champCategorie, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.tous),
                  selected: f.categorie == null,
                  onSelected: (_) => definir(f.copyWith(categorie: () => null)),
                ),
                for (final c in Categorie.values)
                  ChoiceChip(
                    label: Text(l10n.categorie(c)),
                    selected: f.categorie == c,
                    onSelected: (_) => definir(f.copyWith(categorie: () => c)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: f.africain,
              onChanged: (v) => definir(f.copyWith(africain: v)),
              title: Text(l10n.labelAfricain),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: f.chretien,
              onChanged: (v) => definir(f.copyWith(chretien: v)),
              title: Text(l10n.labelChretien),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: f.ouvertMaintenant,
              onChanged: (v) => definir(f.copyWith(ouvertMaintenant: v)),
              title: Text(l10n.ouvertMaintenant),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        definir(FiltresExplorer(recherche: f.recherche)),
                    child: Text(l10n.reinitialiser),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.voirResultats),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
