import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/etat_vide.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAdmin)),
      body: EtatVide(
        icone: Icons.verified_user_outlined,
        titre: l10n.adminVideTitre,
        texte: l10n.adminVideTexte,
      ),
    );
  }
}
