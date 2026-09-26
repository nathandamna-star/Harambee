import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/etat_vide.dart';

class MonEspaceScreen extends StatelessWidget {
  const MonEspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMonEspace)),
      body: EtatVide(
        icone: Icons.person_outline,
        titre: l10n.monEspaceVideTitre,
        texte: l10n.monEspaceVideTexte,
      ),
    );
  }
}
