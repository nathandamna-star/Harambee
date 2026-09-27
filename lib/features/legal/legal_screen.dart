import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum PageLegale { cgu, confidentialite }

/// Affiche une page légale (texte simple : titres « # », « ## », listes « - »,
/// encadrés « > »). Seule la version française existe pour l'instant.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.page, this.bundle});

  final PageLegale page;

  /// Remplaçable dans les tests.
  final AssetBundle? bundle;

  String get _fichier => switch (page) {
    PageLegale.cgu => 'assets/legal/cgu_fr.md',
    PageLegale.confidentialite => 'assets/legal/confidentialite_fr.md',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(page == PageLegale.cgu ? l10n.cgu : l10n.confidentialite),
      ),
      body: FutureBuilder<String>(
        future: (bundle ?? DefaultAssetBundle.of(context)).loadString(_fichier),
        builder: (context, s) {
          if (!s.hasData) {
            return Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
            );
          }
          return SelectionArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (Localizations.localeOf(context).languageCode != 'fr')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      l10n.legalEnFrancais,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                for (final ligne in s.data!.split('\n')) _ligne(ligne, theme),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _ligne(String ligne, ThemeData theme) {
    if (ligne.trim().isEmpty) return const SizedBox(height: 8);
    if (ligne.startsWith('# ')) {
      return Text(ligne.substring(2), style: theme.textTheme.headlineSmall);
    }
    if (ligne.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(ligne.substring(3), style: theme.textTheme.titleMedium),
      );
    }
    if (ligne.startsWith('> ')) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(ligne.substring(2), style: theme.textTheme.bodyMedium),
      );
    }
    if (ligne.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(ligne.substring(2))),
          ],
        ),
      );
    }
    return Text(ligne, style: theme.textTheme.bodyMedium);
  }
}
