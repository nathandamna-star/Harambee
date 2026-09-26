import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/signalement.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../../shared/widgets/label_chip.dart';
import '../../commerce/data/pays.dart';
import '../../commerce/presentation/libelles.dart';
import '../admin_providers.dart';

/// Espace administrateur : fiches à vérifier, publiées, suspendues, signalements.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enAttente = ref
        .watch(commercesParStatutProvider(StatutCommerce.enVerification))
        .value
        ?.length;
    final signalements = ref.watch(signalementsProvider).value?.length;

    String avecNombre(String libelle, int? n) =>
        (n == null || n == 0) ? libelle : '$libelle ($n)';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminVideTitre),
          actions: [
            IconButton(
              tooltip: l10n.tarifs,
              icon: const Icon(Icons.percent),
              onPressed: () => context.push(Routes.tarifs),
            ),
            IconButton(
              tooltip: l10n.administrateurs,
              icon: const Icon(Icons.manage_accounts_outlined),
              onPressed: () => context.push(Routes.administrateurs),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: avecNombre(l10n.adminEnAttente, enAttente)),
              Tab(text: l10n.adminPublies),
              Tab(text: l10n.adminSuspendus),
              Tab(text: avecNombre(l10n.adminSignalements, signalements)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ListeCommerces(StatutCommerce.enVerification),
            _ListeCommerces(StatutCommerce.publie),
            _ListeCommerces(StatutCommerce.suspendu),
            _ListeSignalements(),
          ],
        ),
      ),
    );
  }
}

class _ListeCommerces extends ConsumerWidget {
  const _ListeCommerces(this.statut);

  final StatutCommerce statut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(commercesParStatutProvider(statut))
        .when(
          loading: () => Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
          ),
          error: (_, _) => EtatVide(
            icone: Icons.wifi_off,
            titre: l10n.erreurReseau,
            texte: '',
          ),
          data: (commerces) => commerces.isEmpty
              ? EtatVide(
                  icone: statut == StatutCommerce.enVerification
                      ? Icons.task_alt
                      : Icons.storefront_outlined,
                  titre: statut == StatutCommerce.enVerification
                      ? l10n.adminRienAVerifier
                      : l10n.adminAucunCommerce,
                  texte: '',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: commerces.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _TuileCommerce(commerce: commerces[i]),
                ),
        );
  }
}

class _TuileCommerce extends StatelessWidget {
  const _TuileCommerce({required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final pays = Pays.depuisCode(commerce.pays)?.nom(langue) ?? commerce.pays;
    final date = commerce.createdAt == null
        ? ''
        : ' · ${DateFormat.yMd(langue).format(commerce.createdAt!)}';

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox.square(
            dimension: 56,
            child: commerce.photos.isEmpty
                ? const Icon(Icons.storefront_outlined)
                : Image.network(
                    commerce.photos.first,
                    fit: BoxFit.cover,
                    cacheWidth: 150,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
          ),
        ),
        title: Text(commerce.nom),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.categorie(commerce.categorie)} · ${commerce.ville}, $pays$date',
            ),
            if (commerce.labelAfricain || commerce.labelChretien) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  if (commerce.labelAfricain)
                    const LabelChip(TypeLabel.africain),
                  if (commerce.labelChretien)
                    const LabelChip(TypeLabel.chretien),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.adminCommerce(commerce.id)),
      ),
    );
  }
}

class _ListeSignalements extends ConsumerWidget {
  const _ListeSignalements();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(signalementsProvider)
        .when(
          loading: () => Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
          ),
          error: (_, _) => EtatVide(
            icone: Icons.wifi_off,
            titre: l10n.erreurReseau,
            texte: '',
          ),
          data: (liste) => liste.isEmpty
              ? EtatVide(
                  icone: Icons.flag_outlined,
                  titre: l10n.adminAucunSignalement,
                  texte: '',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: liste.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _TuileSignalement(signalement: liste[i]),
                ),
        );
  }
}

class _TuileSignalement extends ConsumerWidget {
  const _TuileSignalement({required this.signalement});

  final Signalement signalement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final cible = switch (signalement.cible) {
      CibleSignalement.commerce => l10n.cibleCommerce,
      CibleSignalement.avis => l10n.cibleAvis,
      CibleSignalement.message => l10n.cibleMessage,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(cible, style: theme.textTheme.titleSmall)),
                if (signalement.createdAt != null)
                  Text(
                    DateFormat.yMd(langue).format(signalement.createdAt!),
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(signalement.motif),
            const SizedBox(height: 4),
            SelectableText(
              signalement.cibleId,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (signalement.cible == CibleSignalement.commerce)
                  OutlinedButton(
                    onPressed: () =>
                        context.push(Routes.adminCommerce(signalement.cibleId)),
                    child: Text(l10n.voirCommerce),
                  ),
                FilledButton.tonal(
                  onPressed: () => ref
                      .read(adminRepositoryProvider)
                      .marquerTraite(signalement.id),
                  child: Text(l10n.marquerTraite),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
