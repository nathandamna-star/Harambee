import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/etat_vide.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFavoris)),
      body: EtatVide(
        icone: Icons.favorite_border,
        titre: l10n.favorisVideTitre,
        texte: l10n.favorisVideTexte,
      ),
    );
  }
}
