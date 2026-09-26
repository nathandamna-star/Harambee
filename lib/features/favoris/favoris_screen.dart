import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../../shared/widgets/etat_vide.dart';
import '../auth/auth_providers.dart';
import '../explorer/explorer_providers.dart';
import '../explorer/presentation/carte_commerce.dart';

class FavorisScreen extends ConsumerWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final connecte = ref.watch(roleProvider) != null;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navFavoris)),
      body: !connecte
          ? ConnexionRequise(
              icone: Icons.favorite_border,
              texte: l10n.connexionRequiseFavoris,
            )
          : ref
                .watch(commercesFavorisProvider)
                .when(
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: l10n.chargement,
                    ),
                  ),
                  error: (_, _) => EtatVide(
                    icone: Icons.wifi_off,
                    titre: l10n.erreurReseau,
                    texte: '',
                  ),
                  data: (liste) => liste.isEmpty
                      ? EtatVide(
                          icone: Icons.favorite_border,
                          titre: l10n.favorisVideTitre,
                          texte: l10n.favorisVideTexte,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: liste.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => CarteCommerce(
                            commerce: liste[i],
                            onTap: () => context.push(
                              Routes.commerceFavoris(liste[i].id),
                            ),
                          ),
                        ),
                ),
    );
  }
}
