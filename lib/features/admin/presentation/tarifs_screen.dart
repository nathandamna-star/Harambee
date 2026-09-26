import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/tarifs.dart';
import '../../auth/auth_providers.dart';
import '../../commandes/commandes_providers.dart';
import '../../commerce/data/pays.dart';
import '../../commerce/presentation/libelles.dart';

/// Tarifs de la plateforme (`parametres/tarifs`), modifiables par l'admin.
class TarifsScreen extends ConsumerWidget {
  const TarifsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(tarifsProvider)
        .when(
          loading: () => Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
            ),
          ),
          error: (_, _) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.erreurReseau)),
          ),
          data: (t) => _Formulaire(initial: t),
        );
  }
}

/// Valeurs de départ proposées (cahier des charges, section 7 bis). Elles ne
/// s'appliquent qu'une fois enregistrées par l'admin.
const _tarifPropose = TarifRegion(commissionPct: 6, fraisServiceFixe: 0.49);

class _Formulaire extends ConsumerStatefulWidget {
  const _Formulaire({required this.initial});

  final Tarifs initial;

  @override
  ConsumerState<_Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends ConsumerState<_Formulaire> {
  final _formulaire = GlobalKey<FormState>();
  late TarifRegion _defaut = widget.initial.defaut ?? _tarifPropose;
  late final Map<String, TarifRegion> _parPays = {...widget.initial.parPays};
  late final _lancementPct = TextEditingController(
    text: '${widget.initial.lancementCommissionPct}',
  );
  late final _lancementMois = TextEditingController(
    text: '${widget.initial.lancementDureeMois}',
  );
  late DateTime? _inscritsAvant = widget.initial.lancementInscritsAvant;
  bool _occupe = false;

  @override
  void dispose() {
    _lancementPct.dispose();
    _lancementMois.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    if (!_formulaire.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      final tarifs = Tarifs(
        defaut: _defaut,
        parContinent: widget.initial.parContinent,
        parPays: _parPays,
        lancementCommissionPct: lirePrix(_lancementPct.text) ?? 0,
        lancementDureeMois: int.tryParse(_lancementMois.text.trim()) ?? 6,
        lancementInscritsAvant: _inscritsAvant,
      );
      await ref
          .read(firestoreProvider)
          .doc('parametres/tarifs')
          .set(tarifs.versFirestore());
      messenger.showSnackBar(SnackBar(content: Text(l10n.tarifsEnregistres)));
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.erreurEnregistrement)),
      );
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _ajouterPays() async {
    final langue = Localizations.localeOf(context).languageCode;
    final choix = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => ListView(
        children: [
          for (final p in [
            ...Pays.tous,
          ]..sort((a, b) => a.nom(langue).compareTo(b.nom(langue))))
            if (!_parPays.containsKey(p.code))
              ListTile(
                title: Text(p.nom(langue)),
                onTap: () => Navigator.pop(context, p.code),
              ),
        ],
      ),
    );
    if (choix != null) setState(() => _parPays[choix] = _defaut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tarifs)),
      body: SafeArea(
        child: Form(
          key: _formulaire,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(l10n.tarifsAide, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              _EditeurTarif(
                titre: l10n.tarifParDefaut,
                tarif: _defaut,
                onChanged: (t) => _defaut = t,
              ),
              for (final e in _parPays.entries)
                _EditeurTarif(
                  key: ValueKey(e.key),
                  titre: Pays.depuisCode(e.key)?.nom(langue) ?? e.key,
                  tarif: e.value,
                  onChanged: (t) => _parPays[e.key] = t,
                  onSupprimer: () => setState(() => _parPays.remove(e.key)),
                ),
              OutlinedButton.icon(
                onPressed: _ajouterPays,
                icon: const Icon(Icons.add),
                label: Text(l10n.ajouterTarifPays),
              ),
              const Divider(height: 32),
              Text(l10n.periodeLancement, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(l10n.periodeLancementAide, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lancementPct,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.commissionLancement,
                  suffixText: '%',
                ),
                validator: (v) =>
                    lirePrix(v ?? '') == null ? l10n.validationPrix : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lancementMois,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.dureeLancement,
                  suffixText: l10n.mois,
                ),
                validator: (v) => int.tryParse(v?.trim() ?? '') == null
                    ? l10n.validationPrix
                    : null,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.inscritsAvant),
                subtitle: Text(
                  _inscritsAvant == null
                      ? l10n.aucuneDate
                      : DateFormat.yMMMd(langue).format(_inscritsAvant!),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _inscritsAvant ?? DateTime.now(),
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2035),
                  );
                  if (d != null) setState(() => _inscritsAvant = d);
                },
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

class _EditeurTarif extends StatefulWidget {
  const _EditeurTarif({
    super.key,
    required this.titre,
    required this.tarif,
    required this.onChanged,
    this.onSupprimer,
  });

  final String titre;
  final TarifRegion tarif;
  final ValueChanged<TarifRegion> onChanged;
  final VoidCallback? onSupprimer;

  @override
  State<_EditeurTarif> createState() => _EditeurTarifState();
}

class _EditeurTarifState extends State<_EditeurTarif> {
  static String _t(num? v) => v == null ? '' : '$v'.replaceAll('.', ',');

  late final _commission = TextEditingController(
    text: _t(widget.tarif.commissionPct),
  );
  late bool _pourcentage = widget.tarif.fraisServicePct != null;
  late final _fixe = TextEditingController(
    text: _t(widget.tarif.fraisServiceFixe),
  );
  late final _pct = TextEditingController(
    text: _t(widget.tarif.fraisServicePct),
  );
  late final _plafond = TextEditingController(
    text: _t(widget.tarif.fraisServicePlafond),
  );

  @override
  void dispose() {
    for (final c in [_commission, _fixe, _pct, _plafond]) {
      c.dispose();
    }
    super.dispose();
  }

  void _publier() => widget.onChanged(
    TarifRegion(
      commissionPct: lirePrix(_commission.text) ?? 0,
      fraisServiceFixe: _pourcentage ? null : lirePrix(_fixe.text),
      fraisServicePct: _pourcentage ? lirePrix(_pct.text) : null,
      fraisServicePlafond: _pourcentage && _plafond.text.trim().isNotEmpty
          ? lirePrix(_plafond.text)
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String? nombre(String? v) =>
        lirePrix(v ?? '') == null ? l10n.validationPrix : null;
    Widget champ(
      TextEditingController c,
      String libelle,
      String suffixe, {
      bool facultatif = false,
    }) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextFormField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: libelle, suffixText: suffixe),
        validator: facultatif
            ? (v) => (v == null || v.trim().isEmpty) ? null : nombre(v)
            : nombre,
        onChanged: (_) => _publier(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.titre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (widget.onSupprimer != null)
                  IconButton(
                    tooltip: l10n.supprimer,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onSupprimer,
                  ),
              ],
            ),
            champ(_commission, l10n.commission, '%'),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(l10n.fraisFixes)),
                ButtonSegment(value: true, label: Text(l10n.fraisPourcentage)),
              ],
              selected: {_pourcentage},
              onSelectionChanged: (s) {
                setState(() => _pourcentage = s.first);
                _publier();
              },
            ),
            if (_pourcentage) ...[
              champ(_pct, l10n.fraisService, '%'),
              champ(_plafond, l10n.plafond, '', facultatif: true),
            ] else
              champ(_fixe, l10n.fraisService, ''),
          ],
        ),
      ),
    );
  }
}
