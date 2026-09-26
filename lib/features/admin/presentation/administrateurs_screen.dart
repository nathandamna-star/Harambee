import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../admin_providers.dart';
import 'message_erreur_admin.dart';

/// Nommer ou retirer un administrateur par son adresse e-mail.
class AdministrateursScreen extends ConsumerStatefulWidget {
  const AdministrateursScreen({super.key});

  @override
  ConsumerState<AdministrateursScreen> createState() =>
      _AdministrateursScreenState();
}

class _AdministrateursScreenState extends ConsumerState<AdministrateursScreen> {
  final _email = TextEditingController();
  final _formulaire = GlobalKey<FormState>();
  bool _occupe = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _definir(bool admin) async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final email = _email.text.trim();
    setState(() => _occupe = true);
    try {
      await ref.read(fonctionsAdminProvider).definirAdmin(email, admin: admin);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              admin ? l10n.adminNomme(email) : l10n.adminRetire(email),
            ),
          ),
        );
      _email.clear();
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(messageErreurAdmin(l10n, e))));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.administrateurs)),
      body: SafeArea(
        child: Form(
          key: _formulaire,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.administrateursAide),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(labelText: l10n.champEmail),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: (v) =>
                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(v?.trim() ?? '')
                    ? null
                    : l10n.validationEmail,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _occupe ? null : () => _definir(true),
                icon: const Icon(Icons.person_add_alt),
                label: Text(l10n.nommerAdmin),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _occupe ? null : () => _definir(false),
                icon: const Icon(Icons.person_remove_outlined),
                label: Text(l10n.retirerAdmin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
