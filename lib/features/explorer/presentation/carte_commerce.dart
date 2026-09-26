import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/geo.dart';
import '../../../shared/models/horaires.dart';
import '../../../shared/widgets/label_chip.dart';
import '../../commerce/presentation/libelles.dart';
import '../explorer_providers.dart';

/// Carte d'un commerce dans une liste (Explorer, Favoris).
class CarteCommerce extends ConsumerWidget {
  const CarteCommerce({
    super.key,
    required this.commerce,
    required this.onTap,
    this.distanceKm,
  });

  final Commerce commerce;
  final VoidCallback onTap;

  /// Distance depuis l'utilisateur (mode « Près de moi »).
  final double? distanceKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ouvert = estOuvert(commerce.horaires, ref.watch(horlogeProvider)());
    final aDesHoraires = commerce.horaires.values.any((p) => p.isNotEmpty);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8,
              child: commerce.photos.isEmpty
                  ? ColoredBox(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      child: Icon(
                        Icons.storefront_outlined,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Image.network(
                      commerce.photos.first,
                      fit: BoxFit.cover,
                      cacheWidth: 800,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          commerce.nom,
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (commerce.nbAvis > 0) NoteEtoiles(commerce: commerce),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      l10n.categorie(commerce.categorie),
                      commerce.ville,
                      if (distanceKm != null)
                        formaterDistance(
                          distanceKm!,
                          Localizations.localeOf(context).toString(),
                        ),
                    ].join(' · '),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const BadgeVerifie(),
                      if (commerce.labelAfricain)
                        const LabelChip(TypeLabel.africain),
                      if (commerce.labelChretien)
                        const LabelChip(TypeLabel.chretien),
                      if (aDesHoraires)
                        Text(
                          ouvert ? l10n.ouvert : l10n.fermeMaintenant,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: ouvert
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// « ★ 4,5 (12) »
class NoteEtoiles extends StatelessWidget {
  const NoteEtoiles({super.key, required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final note = commerce.noteMoyenne.toStringAsFixed(1);
    final noteLocale = locale.startsWith('en')
        ? note
        : note.replaceAll('.', ',');
    return Semantics(
      label: l10n.noteSur5(noteLocale, commerce.nbAvis),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFE0A100), size: 20),
          const SizedBox(width: 2),
          Text(
            '$noteLocale (${commerce.nbAvis})',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

/// Badge « Vérifié » : toute fiche publiée a été vérifiée par l'équipe.
class BadgeVerifie extends StatelessWidget {
  const BadgeVerifie({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified, size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 2),
        Text(
          AppLocalizations.of(context).badgeVerifie,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
