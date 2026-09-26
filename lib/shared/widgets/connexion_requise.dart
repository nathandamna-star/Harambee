import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';

/// Affiché à la place d'un écran réservé aux utilisateurs connectés.
class ConnexionRequise extends StatelessWidget {
  const ConnexionRequise({super.key, required this.icone, required this.texte});

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(icone, size: 56, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.connexionRequiseTitre,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              texte,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.push(Routes.bienvenue),
              child: Text(l10n.seConnecter),
            ),
          ],
        ),
      ),
    );
  }
}
