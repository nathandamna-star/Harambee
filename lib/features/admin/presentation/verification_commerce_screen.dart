import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/label_chip.dart';
import '../../commerce/commerce_providers.dart';
import '../../commerce/data/pays.dart';
import '../../commerce/presentation/libelles.dart';
import '../admin_providers.dart';

/// Détail d'une fiche pour l'administrateur : vérifier, publier, refuser,
/// suspendre, confirmer les labels.
class VerificationCommerceScreen extends ConsumerWidget {
  const VerificationCommerceScreen({super.key, required this.commerceId});

  final String commerceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(commerceProvider(commerceId))
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
          data: (c) => c == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: Center(child: Text(l10n.commerceIntrouvable)),
                )
              : _Detail(key: ValueKey(c.statut), commerce: c),
        );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({super.key, required this.commerce});

  final Commerce commerce;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  late bool _africain = widget.commerce.labelAfricain;
  late bool _chretien = widget.commerce.labelChretien;
  bool _occupe = false;

  Commerce get c => widget.commerce;

  bool get _labelsModifies =>
      _africain != c.labelAfricain || _chretien != c.labelChretien;

  Future<void> _agir(Future<void> Function() action, String succes) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await action();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(succes)));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.erreurEnregistrement)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _suspendre({required bool refus}) async {
    final l10n = AppLocalizations.of(context);
    final motif = await _demanderMotif(
      context,
      refus ? l10n.refuserFiche : l10n.suspendreFiche,
    );
    if (motif == null) return;
    await _agir(
      () => ref.read(adminRepositoryProvider).suspendre(c.id, motif),
      refus ? l10n.ficheRefusee : l10n.ficheSuspendue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final pays = Pays.depuisCode(c.pays)?.nom(langue) ?? c.pays;
    final horaires = [
      for (final (cle, jour) in l10n.jours)
        '$jour : ${(c.horaires[cle]?.isNotEmpty ?? false) ? c.horaires[cle]!.join(', ') : l10n.ferme}',
    ];

    Widget info(IconData icone, String titre, String? valeur) => ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone),
      title: Text(titre, style: theme.textTheme.labelMedium),
      subtitle: Text(
        (valeur == null || valeur.isEmpty) ? '—' : valeur,
        style: theme.textTheme.bodyLarge,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(c.nom)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Chip(
              avatar: const Icon(Icons.info_outline, size: 18),
              label: Text(l10n.statutCommerce(c.statut)),
            ),
            if (c.motifRefus?.isNotEmpty ?? false)
              Text(
                l10n.motifActuel(c.motifRefus!),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            const SizedBox(height: 12),
            if (c.photos.isEmpty)
              Text(
                l10n.aucunePhoto,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            else
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.photos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      c.photos[i],
                      width: 200,
                      fit: BoxFit.cover,
                      cacheWidth: 600,
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 200,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            info(
              Icons.category_outlined,
              l10n.champCategorie,
              l10n.categorie(c.categorie),
            ),
            info(Icons.notes, l10n.champDescription, c.description),
            info(
              Icons.place_outlined,
              l10n.champAdresse,
              '${c.adresse}\n${c.ville}, $pays',
            ),
            info(
              Icons.my_location,
              l10n.positionGps,
              c.geo == null
                  ? l10n.positionNonRenseignee
                  : '${c.geo!.latitude.toStringAsFixed(5)}, ${c.geo!.longitude.toStringAsFixed(5)}',
            ),
            info(Icons.phone_outlined, l10n.champTelephone, c.telephone),
            info(Icons.schedule, l10n.champHoraires, horaires.join('\n')),
            const Divider(height: 32),
            Text(l10n.labelsAConfirmer, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.labelsAConfirmerAide, style: theme.textTheme.bodySmall),
            SwitchListTile(
              value: _africain,
              onChanged: _occupe ? null : (v) => setState(() => _africain = v),
              title: const Align(
                alignment: Alignment.centerLeft,
                child: LabelChip(TypeLabel.africain),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: _chretien,
              onChanged: _occupe ? null : (v) => setState(() => _chretien = v),
              title: const Align(
                alignment: Alignment.centerLeft,
                child: LabelChip(TypeLabel.chretien),
              ),
              subtitle: Text(
                c.charteSigneeLe == null
                    ? l10n.charteNonSignee
                    : l10n.charteSigneeLe(
                        DateFormat.yMMMd(langue).format(c.charteSigneeLe!),
                      ),
                style: TextStyle(
                  color: c.charteSigneeLe == null
                      ? theme.colorScheme.error
                      : theme.colorScheme.secondary,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            ..._actions(l10n),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(AppLocalizations l10n) {
    if (_occupe) {
      return [
        Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
        ),
      ];
    }
    Future<void> publier() => _agir(
      () => ref
          .read(adminRepositoryProvider)
          .publier(c.id, labelAfricain: _africain, labelChretien: _chretien),
      l10n.fichePubliee,
    );

    return switch (c.statut) {
      StatutCommerce.enVerification => [
        FilledButton.icon(
          onPressed: publier,
          icon: const Icon(Icons.verified),
          label: Text(l10n.publierFiche),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _suspendre(refus: true),
          icon: const Icon(Icons.close),
          label: Text(l10n.refuserFiche),
        ),
      ],
      StatutCommerce.publie => [
        if (_labelsModifies) ...[
          FilledButton(
            onPressed: () => _agir(
              () => ref
                  .read(adminRepositoryProvider)
                  .definirLabels(
                    c.id,
                    labelAfricain: _africain,
                    labelChretien: _chretien,
                  ),
              l10n.labelsEnregistres,
            ),
            child: Text(l10n.enregistrerLabels),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => _suspendre(refus: false),
          icon: const Icon(Icons.block),
          label: Text(l10n.suspendreFiche),
        ),
      ],
      StatutCommerce.suspendu => [
        FilledButton.icon(
          onPressed: publier,
          icon: const Icon(Icons.verified),
          label: Text(l10n.republierFiche),
        ),
      ],
    };
  }
}

/// Demande le motif d'un refus ou d'une suspension (obligatoire).
Future<String?> _demanderMotif(BuildContext context, String titre) =>
    showDialog<String>(
      context: context,
      builder: (context) => _DialogueMotif(titre: titre),
    );

class _DialogueMotif extends StatefulWidget {
  const _DialogueMotif({required this.titre});

  final String titre;

  @override
  State<_DialogueMotif> createState() => _DialogueMotifState();
}

class _DialogueMotifState extends State<_DialogueMotif> {
  // Le contrôleur vit avec la fenêtre : il n'est libéré qu'après sa fermeture
  // complète (animation comprise).
  final _controleur = TextEditingController();
  final _formulaire = GlobalKey<FormState>();

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.titre),
      content: Form(
        key: _formulaire,
        child: TextFormField(
          controller: _controleur,
          autofocus: true,
          maxLines: 3,
          maxLength: 500,
          decoration: InputDecoration(
            labelText: l10n.motif,
            helperText: l10n.motifAide,
            helperMaxLines: 2,
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.champObligatoire : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.annuler),
        ),
        FilledButton(
          onPressed: () {
            if (_formulaire.currentState!.validate()) {
              Navigator.pop(context, _controleur.text.trim());
            }
          },
          child: Text(l10n.valider),
        ),
      ],
    );
  }
}
