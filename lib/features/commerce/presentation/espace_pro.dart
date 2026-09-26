import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/label_chip.dart';
import '../../commandes/commandes_providers.dart';
import '../commerce_providers.dart';
import 'libelles.dart';

/// Partie « professionnel » de Mon espace : fiches et catalogue.
class EspacePro extends ConsumerWidget {
  const EspacePro({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ref
        .watch(mesCommercesProvider)
        .when(
          loading: () => Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
            ),
          ),
          error: (_, _) => Text(l10n.erreurReseau),
          data: (commerces) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.monCommerce, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              if (commerces.isNotEmpty) ...[
                _CarteCommandes(),
                const SizedBox(height: 12),
              ],
              if (commerces.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.aucunCommerceTitre,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(l10n.aucunCommerceTexte),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.push(Routes.nouveauCommerce),
                          icon: const Icon(Icons.storefront_outlined),
                          label: Text(l10n.creerFiche),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final c in commerces) ...[
                  _CarteCommerce(commerce: c),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        );
  }
}

class _CarteCommerce extends StatelessWidget {
  const _CarteCommerce({required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (icone, couleur, explication) = switch (commerce.statut) {
      StatutCommerce.enVerification => (
        Icons.hourglass_top,
        theme.colorScheme.onSurfaceVariant,
        l10n.statutEnVerificationAide,
      ),
      StatutCommerce.publie => (
        Icons.verified,
        theme.colorScheme.secondary,
        l10n.statutPublieAide,
      ),
      StatutCommerce.suspendu => (
        Icons.block,
        theme.colorScheme.error,
        commerce.motifRefus?.isNotEmpty ?? false
            ? l10n.statutSuspenduMotif(commerce.motifRefus!)
            : l10n.statutSuspenduAide,
      ),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (commerce.photos.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                commerce.photos.first,
                fit: BoxFit.cover,
                cacheWidth: 800,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(commerce.nom, style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${l10n.categorie(commerce.categorie)} · ${commerce.ville}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (commerce.labelAfricain || commerce.labelChretien) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (commerce.labelAfricain)
                        const LabelChip(TypeLabel.africain),
                      if (commerce.labelChretien)
                        const LabelChip(TypeLabel.chretien),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(icone, color: couleur, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      l10n.statutCommerce(commerce.statut),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: couleur,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(explication, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.push(Routes.modifierCommerce(commerce.id)),
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.modifierFiche),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.push(Routes.catalogue(commerce.id)),
                        icon: const Icon(Icons.inventory_2_outlined),
                        label: Text(l10n.catalogue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push(Routes.reglagesCommande(commerce.id)),
                  icon: const Icon(Icons.delivery_dining_outlined),
                  label: Text(
                    commerce.commande?.active ?? false
                        ? l10n.commandeActiveModifier
                        : l10n.activerCommande,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Accès à l'onglet Commandes, avec le nombre de nouvelles commandes.
class _CarteCommandes extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nouvelles = ref.watch(nbNouvellesCommandesProvider);
    return Card(
      child: ListTile(
        leading: Badge(
          isLabelVisible: nouvelles > 0,
          label: Text('$nouvelles'),
          child: const Icon(Icons.receipt_long_outlined),
        ),
        title: Text(l10n.commandes),
        subtitle: nouvelles > 0
            ? Text(l10n.nouvellesCommandes(nouvelles))
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(Routes.commandesPro),
      ),
    );
  }
}
