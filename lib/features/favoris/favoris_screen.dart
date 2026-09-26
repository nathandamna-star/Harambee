import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/etat_vide.dart';
import '../auth/auth_providers.dart';

class FavorisScreen extends ConsumerWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connecte = ref.watch(roleProvider) != null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFavoris)),
      body: connecte
          ? EtatVide(
              icone: Icons.favorite_border,
              titre: l10n.favorisVideTitre,
              texte: l10n.favorisVideTexte,
            )
          : ConnexionRequise(
              icone: Icons.favorite_border,
              texte: l10n.connexionRequiseFavoris,
            ),
    );
  }
}
