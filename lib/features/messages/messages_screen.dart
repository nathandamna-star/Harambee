import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/etat_vide.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMessages)),
      body: EtatVide(
        icone: Icons.chat_bubble_outline,
        titre: l10n.messagesVideTitre,
        texte: l10n.messagesVideTexte,
      ),
    );
  }
}
