import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/etat_vide.dart';
import '../auth/auth_providers.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connecte = ref.watch(roleProvider) != null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMessages)),
      body: connecte
          ? EtatVide(
              icone: Icons.chat_bubble_outline,
              titre: l10n.messagesVideTitre,
              texte: l10n.messagesVideTexte,
            )
          : ConnexionRequise(
              icone: Icons.chat_bubble_outline,
              texte: l10n.connexionRequiseMessages,
            ),
    );
  }
}
