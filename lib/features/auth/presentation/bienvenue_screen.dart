import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/preferences/preferences.dart';
import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../auth_providers.dart';
import '../domain/role.dart';
import 'message_erreur_auth.dart';

/// Premier écran : choix client / pro, puis mode de connexion.
class BienvenueScreen extends ConsumerStatefulWidget {
  const BienvenueScreen({super.key});

  @override
  ConsumerState<BienvenueScreen> createState() => _BienvenueScreenState();
}

class _BienvenueScreenState extends ConsumerState<BienvenueScreen> {
  bool _occupe = false;

  Future<void> _connexion(
    Future<void> Function(Role role, String langue) action,
  ) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _occupe = true);
    try {
      await action(
        ref.read(roleSouhaiteProvider),
        Localizations.localeOf(context).languageCode,
      );
      await ref.read(bienvenueVueProvider.notifier).marquer();
    } catch (e) {
      final message = messageErreurAuth(l10n, e);
      if (message != null && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final role = ref.watch(roleSouhaiteProvider);
    final repo = ref.read(authRepositoryProvider);
    final surIos = defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 24),
                Text(
                  l10n.bienvenueTitre,
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.bienvenueSousTitre,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _CarteChoix(
                  icone: Icons.search,
                  titre: l10n.choixClient,
                  detail: l10n.choixClientDetail,
                  selectionne: role == Role.client,
                  onTap: () => ref
                      .read(roleSouhaiteProvider.notifier)
                      .choisir(Role.client),
                ),
                const SizedBox(height: 12),
                _CarteChoix(
                  icone: Icons.storefront_outlined,
                  titre: l10n.choixPro,
                  detail: l10n.choixProDetail,
                  selectionne: role == Role.pro,
                  onTap: () =>
                      ref.read(roleSouhaiteProvider.notifier).choisir(Role.pro),
                ),
                const SizedBox(height: 32),
                if (_occupe)
                  Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: l10n.chargement,
                    ),
                  )
                else ...[
                  FilledButton.icon(
                    onPressed: () => _connexion(
                      (r, l) =>
                          repo.connexionGoogle(roleSouhaite: r, langue: l),
                    ),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: Text(l10n.continuerGoogle),
                  ),
                  if (surIos) ...[
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.onSurface,
                        foregroundColor: theme.colorScheme.surface,
                      ),
                      onPressed: () => _connexion(
                        (r, l) =>
                            repo.connexionApple(roleSouhaite: r, langue: l),
                      ),
                      icon: const Icon(Icons.apple),
                      label: Text(l10n.continuerApple),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => context.push(Routes.connexionEmail),
                    icon: const Icon(Icons.mail_outline),
                    label: Text(l10n.continuerEmail),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await ref.read(bienvenueVueProvider.notifier).marquer();
                      if (context.mounted) context.go(Routes.explorer);
                    },
                    child: Text(l10n.explorerSansCompte),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarteChoix extends StatelessWidget {
  const _CarteChoix({
    required this.icone,
    required this.titre,
    required this.detail,
    required this.selectionne,
    required this.onTap,
  });

  final IconData icone;
  final String titre;
  final String detail;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Semantics(
      selected: selectionne,
      button: true,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selectionne ? couleurs.primary : couleurs.outline,
            width: selectionne ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Icon(icone, color: couleurs.primary),
          title: Text(titre),
          subtitle: Text(detail),
          trailing: selectionne
              ? Icon(Icons.check_circle, color: couleurs.primary)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
