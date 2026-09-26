import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences/preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../auth_providers.dart';
import 'message_erreur_auth.dart';

/// Connexion ou création de compte par e-mail et mot de passe.
class ConnexionEmailScreen extends ConsumerStatefulWidget {
  const ConnexionEmailScreen({super.key});

  @override
  ConsumerState<ConnexionEmailScreen> createState() =>
      _ConnexionEmailScreenState();
}

class _ConnexionEmailScreenState extends ConsumerState<ConnexionEmailScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _motDePasse = TextEditingController();
  bool _inscription = false;
  bool _motDePasseVisible = false;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _email.dispose();
    _motDePasse.dispose();
    super.dispose();
  }

  Future<void> _valider() async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final repo = ref.read(authRepositoryProvider);
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      if (_inscription) {
        await repo.inscriptionEmail(
          nom: _nom.text,
          email: _email.text,
          motDePasse: _motDePasse.text,
          roleSouhaite: ref.read(roleSouhaiteProvider),
          langue: langue,
        );
      } else {
        await repo.connexionEmail(
          email: _email.text,
          motDePasse: _motDePasse.text,
        );
      }
      await ref.read(bienvenueVueProvider.notifier).marquer();
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurAuth(l10n, e));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _motDePasseOublie() async {
    final l10n = AppLocalizations.of(context);
    if (!_emailValide(_email.text)) {
      setState(() => _erreur = l10n.validationEmail);
      return;
    }
    try {
      await ref.read(authRepositoryProvider).motDePasseOublie(_email.text);
      if (!mounted) return;
      setState(() => _erreur = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.emailReinitialisationEnvoye(_email.text.trim())),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _erreur = messageErreurAuth(l10n, e));
    }
  }

  static bool _emailValide(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_inscription ? l10n.creerCompte : l10n.seConnecter),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Form(
              key: _formulaire,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.seConnecter),
                      ),
                      ButtonSegment(value: true, label: Text(l10n.creerCompte)),
                    ],
                    selected: {_inscription},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() {
                      _inscription = s.first;
                      _erreur = null;
                    }),
                  ),
                  const SizedBox(height: 24),
                  if (_inscription) ...[
                    TextFormField(
                      controller: _nom,
                      decoration: InputDecoration(labelText: l10n.champNom),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.validationNomRequis
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: l10n.champEmail),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    validator: (v) =>
                        _emailValide(v ?? '') ? null : l10n.validationEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _motDePasse,
                    decoration: InputDecoration(
                      labelText: l10n.champMotDePasse,
                      suffixIcon: IconButton(
                        tooltip: _motDePasseVisible
                            ? l10n.masquerMotDePasse
                            : l10n.afficherMotDePasse,
                        icon: Icon(
                          _motDePasseVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _motDePasseVisible = !_motDePasseVisible,
                        ),
                      ),
                    ),
                    obscureText: !_motDePasseVisible,
                    textInputAction: TextInputAction.done,
                    autofillHints: [
                      _inscription
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    onFieldSubmitted: (_) => _valider(),
                    validator: (v) => (v == null || v.length < 8)
                        ? l10n.validationMotDePasse
                        : null,
                  ),
                  if (_erreur != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _erreur!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _occupe ? null : _valider,
                    child: _occupe
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: l10n.chargement,
                            ),
                          )
                        : Text(
                            _inscription ? l10n.creerCompte : l10n.seConnecter,
                          ),
                  ),
                  if (!_inscription)
                    TextButton(
                      onPressed: _occupe ? null : _motDePasseOublie,
                      child: Text(l10n.motDePasseOublie),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
