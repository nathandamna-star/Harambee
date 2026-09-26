import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/connexion_requise.dart';
import '../admin/admin_providers.dart';
import '../admin/presentation/message_erreur_admin.dart';
import '../auth/auth_providers.dart';
import '../notifications/notifications_providers.dart';
import '../auth/domain/role.dart';
import '../commerce/presentation/espace_pro.dart';

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
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              // Appui long : activation du premier administrateur (voir
              // functions/index.js, revendiquerAdminInitial).
              onLongPress: role == Role.admin
                  ? null
                  : () => _activerAdmin(context, ref),
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
          ),
          const SizedBox(height: 24),
          if (role == Role.pro)
            const EspacePro()
          else if (role == Role.client)
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.storefront_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(l10n.vousAvezUnCommerce),
                subtitle: Text(l10n.vousAvezUnCommerceAide),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ref.read(authRepositoryProvider).devenirPro(),
              ),
            ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(notificationsServiceProvider).desactiver(user.uid);
              await ref.read(authRepositoryProvider).deconnexion();
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.seDeconnecter),
          ),
        ],
      ),
    );
  }

  Future<void> _activerAdmin(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activerAdminTitre),
        content: Text(l10n.activerAdminTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.valider),
          ),
        ],
      ),
    );
    if (confirme != true) return;
    try {
      await ref.read(fonctionsAdminProvider).revendiquerAdminInitial();
      await ref.read(authRepositoryProvider).rafraichirJeton();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.adminActive)));
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(messageErreurAdmin(l10n, e))));
    }
  }
}
