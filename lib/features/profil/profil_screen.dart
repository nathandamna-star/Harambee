import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/preferences/langue.dart';
import '../../core/router/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/models/enums.dart';
import '../auth/auth_providers.dart';
import '../notifications/notifications_providers.dart';
import 'compte_service.dart';

final compteServiceProvider = Provider<CompteService>(
  (ref) => CompteServiceFirebase(
    FirebaseFunctions.instanceFor(region: 'europe-west1'),
  ),
);

/// Profil et réglages : nom, langue, devise, pages légales, suppression.
class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  bool _suppression = false;

  Future<void> _modifierNom(String actuel) async {
    final l10n = AppLocalizations.of(context);
    final controleur = TextEditingController(text: actuel);
    final nom = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.champNom),
        content: TextField(
          controller: controleur,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controleur.text.trim()),
            child: Text(l10n.enregistrer),
          ),
        ],
      ),
    );
    if (nom == null || nom.isEmpty) return;
    final user = ref.read(utilisateurFirebaseProvider).value;
    if (user == null) return;
    await ref.read(firestoreProvider).doc('users/${user.uid}').update({
      'nom': nom,
    });
    await user.updateDisplayName(nom);
  }

  Future<void> _mettreAJourProfil(Map<String, dynamic> donnees) async {
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    if (uid == null) return;
    await ref.read(firestoreProvider).doc('users/$uid').update(donnees);
  }

  Future<void> _supprimer() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => const _ConfirmationSuppression(),
    );
    if (confirme != true) return;
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    setState(() => _suppression = true);
    try {
      if (uid != null) {
        await ref.read(notificationsServiceProvider).desactiver(uid);
      }
      await ref.read(compteServiceProvider).supprimerMonCompte();
      await ref.read(authRepositoryProvider).deconnexion();
      messenger.showSnackBar(SnackBar(content: Text(l10n.compteSupprime)));
      router.go(Routes.explorer);
    } on ErreurSuppression catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(switch (e.code) {
            'commandes-en-cours' => l10n.erreurSuppressionCommandes,
            'reseau' => l10n.erreurReseau,
            _ => l10n.erreurInconnue,
          }),
        ),
      );
    } finally {
      if (mounted) setState(() => _suppression = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profil = ref.watch(profilProvider).value;
    final langue = ref.watch(langueAppProvider);
    final langues = {
      null: l10n.langueAuto,
      'fr': 'Français',
      'en': 'English',
      'pt': 'Português',
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilEtReglages)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (profil != null)
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l10n.champNom),
              subtitle: Text(profil.nom.isEmpty ? '—' : profil.nom),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _modifierNom(profil.nom),
            ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.langue),
            trailing: DropdownButton<String?>(
              value: langue,
              underline: const SizedBox.shrink(),
              items: [
                for (final e in langues.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (l) async {
                await ref.read(langueAppProvider.notifier).definir(l);
                // Langue des notifications envoyées par le serveur.
                if (l != null) await _mettreAJourProfil({'langue': l});
              },
            ),
          ),
          if (profil != null)
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: Text(l10n.devisePreferee),
              subtitle: Text(l10n.devisePrefereeAide),
              trailing: DropdownButton<String?>(
                value: profil.devise,
                underline: const SizedBox.shrink(),
                hint: const Text('—'),
                items: [
                  for (final d in Devise.values)
                    DropdownMenuItem(value: d.name, child: Text(d.name)),
                ],
                onChanged: (d) => _mettreAJourProfil({'devise': d}),
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.cgu),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.cgu),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.confidentialite),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.confidentialite),
          ),
          if (profil != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _suppression
                  ? Center(
                      child: CircularProgressIndicator(
                        semanticsLabel: l10n.chargement,
                      ),
                    )
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      onPressed: _supprimer,
                      icon: const Icon(Icons.delete_forever_outlined),
                      label: Text(l10n.supprimerMonCompte),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Confirmation écrite avant suppression (le mot demandé dépend de la langue).
class _ConfirmationSuppression extends StatefulWidget {
  const _ConfirmationSuppression();

  @override
  State<_ConfirmationSuppression> createState() =>
      _ConfirmationSuppressionState();
}

class _ConfirmationSuppressionState extends State<_ConfirmationSuppression> {
  final _texte = TextEditingController();

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mot = l10n.motConfirmationSuppression;
    return AlertDialog(
      title: Text(l10n.supprimerCompteTitre),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.supprimerCompteTexte),
          const SizedBox(height: 16),
          TextField(
            controller: _texte,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: l10n.tapezPourConfirmer(mot),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: _texte.text.trim().toUpperCase() == mot
              ? () => Navigator.pop(context, true)
              : null,
          child: Text(l10n.supprimerDefinitivement),
        ),
      ],
    );
  }
}
