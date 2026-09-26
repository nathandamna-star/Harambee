import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/label_chip.dart';
import '../../auth/auth_providers.dart';
import '../commerce_providers.dart';
import '../data/commerce_repository.dart';
import '../data/localisation_service.dart';
import '../data/pays.dart';
import 'charte_screen.dart';
import 'choisir_position_screen.dart';
import 'editeur_horaires.dart';
import 'grille_photos.dart';
import 'libelles.dart';

/// Création (3 étapes) ou modification de la fiche d'un commerce.
class FicheCommerceScreen extends ConsumerWidget {
  const FicheCommerceScreen({super.key, this.commerceId});

  /// Null pour une nouvelle fiche.
  final String? commerceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (commerceId == null) return const _Formulaire(existant: null);
    final l10n = AppLocalizations.of(context);
    return ref
        .watch(commerceProvider(commerceId!))
        .when(
          data: (c) => c == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: Center(child: Text(l10n.erreurInconnue)),
                )
              : _Formulaire(existant: c),
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
        );
  }
}

class _Formulaire extends ConsumerStatefulWidget {
  const _Formulaire({required this.existant});

  final Commerce? existant;

  @override
  ConsumerState<_Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends ConsumerState<_Formulaire> {
  static const _nbEtapes = 3;

  final _formulaire = GlobalKey<FormState>();
  late final _nom = TextEditingController(text: widget.existant?.nom);
  late final _description = TextEditingController(
    text: widget.existant?.description,
  );
  late final _adresse = TextEditingController(text: widget.existant?.adresse);
  late final _ville = TextEditingController(text: widget.existant?.ville);
  late final _telephone = TextEditingController(
    text: widget.existant?.telephone,
  );

  late Categorie? _categorie = widget.existant?.categorie;
  late String? _pays = widget.existant?.pays;
  late Devise _devise = widget.existant?.devise ?? Devise.EUR;
  late GeoPoint? _geo = widget.existant?.geo;
  late Map<String, List<String>> _horaires = widget.existant?.horaires ?? {};
  late bool _labelAfricain = widget.existant?.labelAfricain ?? false;
  late bool _labelChretien = widget.existant?.labelChretien ?? false;
  late DateTime? _charteSigneeLe = widget.existant?.charteSigneeLe;
  late List<PhotoFiche> _photos = [
    for (final url in widget.existant?.photos ?? const <String>[])
      PhotoFiche.enLigne(url),
  ];

  int _etape = 0;
  bool _occupe = false;
  bool _localisationEnCours = false;
  String? _erreur;

  bool get _modification => widget.existant != null;

  @override
  void dispose() {
    for (final c in [_nom, _description, _adresse, _ville, _telephone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _localiser() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _localisationEnCours = true);
    try {
      final geo = await ref
          .read(localisationServiceProvider)
          .positionActuelle();
      setState(() => _geo = geo);
    } on ExceptionLocalisation catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (e.erreur) {
            ErreurLocalisation.serviceDesactive => l10n.localisationDesactivee,
            ErreurLocalisation.permissionRefusee => l10n.localisationRefusee,
            ErreurLocalisation.inconnue => l10n.localisationIndisponible,
          }),
        ),
      );
    } finally {
      if (mounted) setState(() => _localisationEnCours = false);
    }
  }

  Future<void> _ouvrirCharte() async {
    final accepte = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const CharteScreen()));
    if (accepte == true) {
      setState(() {
        _charteSigneeLe = DateTime.now();
        _labelChretien = true;
        _erreur = null;
      });
    }
  }

  bool _etapeValide() {
    final l10n = AppLocalizations.of(context);
    switch (_etape) {
      case 0:
        final ok = _formulaire.currentState!.validate();
        if (ok && _categorie == null) {
          setState(() => _erreur = l10n.validationCategorie);
          return false;
        }
        return ok;
      case 1:
        if (_labelChretien && _charteSigneeLe == null) {
          setState(() => _erreur = l10n.validationCharte);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _suivant() {
    setState(() => _erreur = null);
    if (!_etapeValide()) return;
    if (_etape < _nbEtapes - 1) {
      setState(() => _etape++);
    } else {
      _enregistrer();
    }
  }

  Future<void> _enregistrer() async {
    final l10n = AppLocalizations.of(context);
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    if (uid == null) return;
    final pays = Pays.depuisCode(_pays)!;
    final commerce = Commerce(
      id: widget.existant?.id ?? '',
      nom: _nom.text.trim(),
      categorie: _categorie!,
      proprietaire: widget.existant?.proprietaire ?? uid,
      continent: pays.continent,
      pays: pays.code,
      ville: _ville.text.trim(),
      adresse: _adresse.text.trim(),
      description: _description.text.trim(),
      telephone: _telephone.text.trim().isEmpty ? null : _telephone.text.trim(),
      geo: _geo,
      horaires: _horaires,
      devise: _devise,
      labelAfricain: _labelAfricain,
      labelChretien: _labelChretien,
      charteSigneeLe: _labelChretien ? _charteSigneeLe : null,
      photos: widget.existant?.photos ?? const [],
    );
    setState(() => _occupe = true);
    try {
      final repo = ref.read(commerceRepositoryProvider);
      if (_modification) {
        await repo.modifier(commerce, _photos);
      } else {
        await repo.creer(commerce, _photos);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _modification ? l10n.ficheEnregistree : l10n.ficheEnvoyee,
          ),
        ),
      );
      context.go(Routes.monEspace);
    } catch (_) {
      if (mounted) setState(() => _erreur = l10n.erreurEnregistrement);
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final titresEtapes = [l10n.etapeInfos, l10n.etapeLabels, l10n.etapePhotos];

    return Scaffold(
      appBar: AppBar(
        title: Text(_modification ? l10n.modifierFiche : l10n.creerFiche),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_etape + 1) / _nbEtapes,
              semanticsLabel: l10n.etapeXsurY(_etape + 1, _nbEtapes),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titresEtapes[_etape],
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  Text(
                    l10n.etapeXsurY(_etape + 1, _nbEtapes),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formulaire,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: switch (_etape) {
                    0 => _etapeInfos(l10n),
                    1 => _etapeLabels(l10n),
                    _ => _etapePhotos(l10n),
                  },
                ),
              ),
            ),
            if (_erreur != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _erreur!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_etape > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _occupe
                            ? null
                            : () => setState(() {
                                _etape--;
                                _erreur = null;
                              }),
                        child: Text(l10n.precedent),
                      ),
                    ),
                  if (_etape > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _occupe ? null : _suivant,
                      child: _occupe
                          ? SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                semanticsLabel: l10n.chargement,
                              ),
                            )
                          : Text(
                              _etape < _nbEtapes - 1
                                  ? l10n.suivant
                                  : (_modification
                                        ? l10n.enregistrer
                                        : l10n.envoyerPourVerification),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _etapeInfos(AppLocalizations l10n) {
    final langue = Localizations.localeOf(context).languageCode;
    final requis = l10n.champObligatoire;
    String? obligatoire(String? v) =>
        (v == null || v.trim().isEmpty) ? requis : null;
    final pays = [...Pays.tous]
      ..sort((a, b) => a.nom(langue).compareTo(b.nom(langue)));

    return [
      TextFormField(
        controller: _nom,
        decoration: InputDecoration(labelText: l10n.champNomCommerce),
        textCapitalization: TextCapitalization.words,
        maxLength: 120,
        validator: obligatoire,
      ),
      const SizedBox(height: 8),
      Text(l10n.champCategorie, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in Categorie.values)
            ChoiceChip(
              label: Text(l10n.categorie(c)),
              selected: _categorie == c,
              onSelected: (_) => setState(() {
                _categorie = c;
                _erreur = null;
              }),
            ),
        ],
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _description,
        decoration: InputDecoration(labelText: l10n.champDescription),
        maxLines: 4,
        maxLength: 1000,
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        initialValue: _pays,
        isExpanded: true,
        decoration: InputDecoration(labelText: l10n.champPays),
        items: [
          for (final p in pays)
            DropdownMenuItem(value: p.code, child: Text(p.nom(langue))),
        ],
        onChanged: (code) => setState(() {
          _pays = code;
          // Devise proposée selon le pays (modifiable ensuite).
          _devise = Pays.depuisCode(code)?.devise ?? _devise;
        }),
        validator: obligatoire,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _ville,
        decoration: InputDecoration(labelText: l10n.champVille),
        textCapitalization: TextCapitalization.words,
        validator: obligatoire,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _adresse,
        decoration: InputDecoration(labelText: l10n.champAdresse),
        validator: obligatoire,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _telephone,
        decoration: InputDecoration(labelText: l10n.champTelephone),
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<Devise>(
        initialValue: _devise,
        decoration: InputDecoration(labelText: l10n.champDevise),
        items: [
          for (final d in Devise.values)
            DropdownMenuItem(value: d, child: Text(d.name)),
        ],
        onChanged: (d) => setState(() => _devise = d ?? _devise),
      ),
      const SizedBox(height: 16),
      Card(
        child: ListTile(
          leading: Icon(
            _geo == null ? Icons.location_searching : Icons.location_on,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            _geo == null ? l10n.positionAbsente : l10n.positionEnregistree,
          ),
          subtitle: Text(l10n.positionAide),
          trailing: _localisationEnCours
              ? SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: l10n.chargement,
                  ),
                )
              : null,
          onTap: _localisationEnCours ? null : _localiser,
        ),
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () async {
            final choisie = await Navigator.of(context).push<GeoPoint>(
              MaterialPageRoute(
                builder: (_) => ChoisirPositionScreen(initiale: _geo),
              ),
            );
            if (choisie != null) setState(() => _geo = choisie);
          },
          icon: const Icon(Icons.map_outlined),
          label: Text(l10n.ajusterPosition),
        ),
      ),
      const SizedBox(height: 16),
      ExpansionTile(
        title: Text(l10n.champHoraires),
        tilePadding: EdgeInsets.zero,
        children: [
          EditeurHoraires(
            horaires: _horaires,
            onChanged: (h) => setState(() => _horaires = h),
          ),
        ],
      ),
    ];
  }

  List<Widget> _etapeLabels(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return [
      Text(
        _modification ? l10n.labelsModifiablesAdmin : l10n.labelsExplication,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 16),
      CheckboxListTile(
        value: _labelAfricain,
        onChanged: _modification
            ? null
            : (v) => setState(() => _labelAfricain = v ?? false),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: LabelChip(TypeLabel.africain),
        ),
        subtitle: Text(l10n.labelAfricainDetail),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      CheckboxListTile(
        value: _labelChretien,
        onChanged: _modification
            ? null
            : (v) => setState(() {
                _labelChretien = v ?? false;
                _erreur = null;
              }),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: LabelChip(TypeLabel.chretien),
        ),
        subtitle: Text(l10n.labelChretienDetail),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
      ),
      if (_labelChretien && !_modification) ...[
        const SizedBox(height: 8),
        _charteSigneeLe == null
            ? OutlinedButton.icon(
                onPressed: _ouvrirCharte,
                icon: const Icon(Icons.description_outlined),
                label: Text(l10n.lireCharte),
              )
            : ListTile(
                leading: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.secondary,
                ),
                title: Text(l10n.charteAcceptee),
                contentPadding: EdgeInsets.zero,
              ),
      ],
    ];
  }

  List<Widget> _etapePhotos(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return [
      Text(
        l10n.photosAide(CommerceRepository.maxPhotosFiche),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 16),
      GrillePhotos(
        photos: _photos,
        onChanged: (p) => setState(() => _photos = p),
      ),
    ];
  }
}
