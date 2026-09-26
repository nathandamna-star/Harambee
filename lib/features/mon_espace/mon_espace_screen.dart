import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../auth/auth_providers.dart';
import '../auth/domain/role.dart';

class MonEspaceScreen extends ConsumerWidget {
  const MonEspaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final role = ref.watch(roleProvider);
    final user = ref.watch(utilisateurFirebaseProvider).value;
    final profil = ref.watch(profilProvider).value;

    if (role == null || user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.navMonEspace)),
        body: ConnexionRequise(
          icone: Icons.person_outline,
          texte: l10n.monEspaceVideTexte,
        ),
      );
    }

    final nom = (profil?.nom.isNotEmpty ?? false)
        ? profil!.nom
        : (user.displayName ?? '');
    final libelleRole = switch (role) {
      Role.client => l10n.roleClient,
      Role.pro => l10n.rolePro,
      Role.admin => l10n.roleAdmin,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navMonEspace)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.monEspaceBonjour(nom),
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Chip(label: Text(libelleRole)),
                ],
              ),
            ),
          ),
          if (role == Role.pro) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.storefront_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.monEspaceProBientot),
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).deconnexion(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.seDeconnecter),
          ),
        ],
      ),
    );
  }
}
