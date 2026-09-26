import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/etat_vide.dart';
import '../../shared/widgets/label_chip.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              children: [
                LabelChip(TypeLabel.africain),
                LabelChip(TypeLabel.chretien),
              ],
            ),
          ),
          Expanded(
            child: EtatVide(
              icone: Icons.storefront_outlined,
              titre: l10n.explorerVideTitre,
              texte: l10n.explorerVideTexte,
            ),
          ),
        ],
      ),
    );
  }
}
