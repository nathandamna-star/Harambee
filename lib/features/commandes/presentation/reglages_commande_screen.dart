import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/models/commerce.dart';
import '../../commerce/commerce_providers.dart';
import '../../commerce/presentation/libelles.dart';

/// Réglages de la commande en ligne d'un commerce.
class ReglagesCommandeScreen extends ConsumerWidget {
  const ReglagesCommandeScreen({super.key, required this.commerceId});

  final String commerceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final commerce = ref.watch(commerceProvider(commerceId)).value;
    if (commerce == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
        ),
      );
    }
    return _Formulaire(commerce: commerce);
  }
}

class _Formulaire extends ConsumerStatefulWidget {
  const _Formulaire({required this.commerce});

  final Commerce commerce;

  @override
  ConsumerState<_Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends ConsumerState<_Formulaire> {
  late final ReglagesCommande _initial =
      widget.commerce.commande ??
      ReglagesCommande(devise: widget.commerce.devise);
  final _formulaire = GlobalKey<FormState>();
  late bool _active = _initial.active;
  late Set<ModeCommande> _modes = {..._initial.modes};
  late bool _especes = _initial.especesAcceptees;
  late final _minimum = _champ(_initial.minimumCommande);
  late final _minimumLivraison = _champ(_initial.minimumLivraison);
  late final _frais = _champ(_initial.fraisLivraison);
  late final _gratuite = TextEditingController(
    text: _initial.livraisonGratuiteDes == null
        ? ''
        : _texte(_initial.livraisonGratuiteDes!),
  );
  late final _rayon = _champ(_initial.rayonLivraisonKm);
  late final _delai = TextEditingController(
    text: '${_initial.delaiPreparationMin}',
  );
  bool _occupe = false;

  static String _texte(num v) => v.toString().replaceAll('.', ',');
  static TextEditingController _champ(num v) =>
      TextEditingController(text: _texte(v));

  @override
  void dispose() {
    for (final c in [
      _minimum,
      _minimumLivraison,
      _frais,
      _gratuite,
      _rayon,
      _delai,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    if (_active && _modes.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.validationModes)));
      return;
    }
    final reglages = ReglagesCommande(
      active: _active,
      modes: _modes,
      minimumCommande: lirePrix(_minimum.text) ?? 0,
      minimumLivraison: lirePrix(_minimumLivraison.text) ?? 0,
      fraisLivraison: lirePrix(_frais.text) ?? 0,
      livraisonGratuiteDes: _gratuite.text.trim().isEmpty
          ? null
          : lirePrix(_gratuite.text),
      rayonLivraisonKm: lirePrix(_rayon.text) ?? 5,
      delaiPreparationMin: int.tryParse(_delai.text.trim()) ?? 30,
      especesAcceptees: _especes,
      devise: widget.commerce.devise,
    );
    setState(() => _occupe = true);
    try {
      await ref
          .read(commerceRepositoryProvider)
          .definirReglagesCommande(widget.commerce.id, reglages);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reglagesEnregistres)));
      context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.erreurEnregistrement)));
      }
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final devise = widget.commerce.devise.name;
    final livraison = _modes.contains(ModeCommande.livraison);
    String? montant(String? v, {bool facultatif = false}) {
      if (facultatif && (v == null || v.trim().isEmpty)) return null;
      return lirePrix(v ?? '') == null ? l10n.validationPrix : null;
    }

    Widget champMontant(
      TextEditingController c,
      String libelle, {
      String? aide,
      bool facultatif = false,
      String? suffixe,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: libelle,
          helperText: aide,
          helperMaxLines: 2,
          suffixText: suffixe ?? devise,
        ),
        validator: (v) => montant(v, facultatif: facultatif),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commandeEtLivraison)),
      body: SafeArea(
        child: Form(
          key: _formulaire,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                value: _active,
                onChanged: (v) => setState(() => _active = v),
                title: Text(l10n.activerCommande),
                subtitle: Text(l10n.activerCommandeAide),
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(height: 32),
              Text(l10n.modesCommande, style: theme.textTheme.titleMedium),
              CheckboxListTile(
                value: _modes.contains(ModeCommande.emporter),
                onChanged: (v) => setState(
                  () =>
                      v == true
                            ? _modes = {..._modes, ModeCommande.emporter}
                            : _modes = {..._modes}
                        ..remove(ModeCommande.emporter),
                ),
                title: Text(l10n.modeEmporter),
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: livraison,
                onChanged: (v) => setState(
                  () =>
                      v == true
                            ? _modes = {..._modes, ModeCommande.livraison}
                            : _modes = {..._modes}
                        ..remove(ModeCommande.livraison),
                ),
                title: Text(l10n.modeLivraison),
                subtitle: Text(l10n.modeLivraisonAide),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              champMontant(
                _minimum,
                l10n.minimumCommande,
                aide: l10n.minimumCommandeAide,
              ),
              if (livraison) ...[
                champMontant(_minimumLivraison, l10n.minimumLivraison),
                champMontant(_frais, l10n.fraisLivraison),
                champMontant(
                  _gratuite,
                  l10n.livraisonGratuiteDes,
                  aide: l10n.livraisonGratuiteAide,
                  facultatif: true,
                ),
                champMontant(_rayon, l10n.rayonLivraison, suffixe: 'km'),
              ],
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: _delai,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.delaiPreparation,
                    suffixText: 'min',
                  ),
                  validator: (v) => int.tryParse(v?.trim() ?? '') == null
                      ? l10n.validationPrix
                      : null,
                ),
              ),
              SwitchListTile(
                value: _especes,
                onChanged: (v) => setState(() => _especes = v),
                title: Text(l10n.accepterEspeces),
                subtitle: Text(l10n.accepterEspecesAide),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  widget.commerce.paiementCarteActif
                      ? Icons.credit_card
                      : Icons.credit_card_off_outlined,
                ),
                title: Text(l10n.paiementCarte),
                subtitle: Text(
                  widget.commerce.paiementCarteActif
                      ? l10n.paiementCarteActif
                      : l10n.paiementCarteBientot,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _occupe ? null : _enregistrer,
                child: Text(l10n.enregistrer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
