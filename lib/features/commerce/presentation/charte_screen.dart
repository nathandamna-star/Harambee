import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Charte à accepter pour demander le label « Chrétien ».
/// Renvoie true si elle est acceptée.
class CharteScreen extends StatefulWidget {
  const CharteScreen({super.key});

  @override
  State<CharteScreen> createState() => _CharteScreenState();
}

class _CharteScreenState extends State<CharteScreen> {
  bool _accepte = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.charteTitre)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Texte définitif fourni plus tard par le porteur du projet.
            Text(l10n.charteTexteProvisoire, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 24),
            CheckboxListTile(
              value: _accepte,
              onChanged: (v) => setState(() => _accepte = v ?? false),
              title: Text(l10n.charteJAccepte),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _accepte ? () => Navigator.pop(context, true) : null,
              child: Text(l10n.valider),
            ),
          ],
        ),
      ),
    );
  }
}
