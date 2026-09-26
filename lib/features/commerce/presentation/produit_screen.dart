import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/produit.dart';
import '../commerce_providers.dart';
import 'grille_photos.dart';
import 'libelles.dart';

/// Modification d'un produit ouvert par son adresse : le produit est passé
/// directement depuis le catalogue, ou relu depuis Firestore sinon.
class ProduitParIdScreen extends ConsumerWidget {
  const ProduitParIdScreen({
    super.key,
    required this.commerceId,
    required this.produitId,
    this.produit,
  });

  final String commerceId;
  final String produitId;
  final Produit? produit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (produit != null) {
      return ProduitScreen(commerceId: commerceId, produit: produit);
    }
    final l10n = AppLocalizations.of(context);
    final liste = ref.watch(produitsProvider(commerceId)).value;
    if (liste == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
        ),
      );
    }
    final trouve = liste.where((p) => p.id == produitId).firstOrNull;
    if (trouve == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.produitIntrouvable)),
      );
    }
    return ProduitScreen(commerceId: commerceId, produit: trouve);
  }
}

/// Ajout ou modification d'un produit du catalogue.
class ProduitScreen extends ConsumerStatefulWidget {
  const ProduitScreen({super.key, required this.commerceId, this.produit});

  final String commerceId;

  /// Null pour un nouveau produit.
  final Produit? produit;

  @override
  ConsumerState<ProduitScreen> createState() => _ProduitScreenState();
}

class _ProduitScreenState extends ConsumerState<ProduitScreen> {
  final _formulaire = GlobalKey<FormState>();
  late final _nom = TextEditingController(text: widget.produit?.nom);
  late final _description = TextEditingController(
    text: widget.produit?.description,
  );
  late final _prix = TextEditingController(
    text: widget.produit?.prix.toString().replaceAll('.', ','),
  );
  Devise? _devise;
  late bool _publie = widget.produit?.publie ?? true;
  Uint8List? _nouvellePhoto;
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _nom.dispose();
    _description.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _choisirPhoto() async {
    final camera = await choisirSourcePhoto(
      context,
      AppLocalizations.of(context),
    );
    if (camera == null) return;
    final octets = await ref
        .read(selecteurPhotoProvider)
        .choisir(camera: camera);
    if (octets != null) setState(() => _nouvellePhoto = octets);
  }

  Future<void> _enregistrer(Devise devise) async {
    if (!_formulaire.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final existant = widget.produit;
    final produit = Produit(
      id: existant?.id ?? '',
      nom: _nom.text.trim(),
      description: _description.text.trim(),
      prix: lirePrix(_prix.text)!,
      devise: devise,
      publie: _publie,
      enRupture: existant?.enRupture ?? false,
      ordre: existant?.ordre ?? 0,
      photoUrl: existant?.photoUrl,
    );
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      await ref
          .read(commerceRepositoryProvider)
          .enregistrerProduit(
            widget.commerceId,
            produit,
            nouvellePhoto: _nouvellePhoto,
          );
      if (mounted) context.pop();
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
    final commerce = ref.watch(commerceProvider(widget.commerceId)).value;
    final devise =
        _devise ?? widget.produit?.devise ?? commerce?.devise ?? Devise.EUR;
    final photoUrl = widget.produit?.photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.produit == null ? l10n.ajouterProduit : l10n.modifierProduit,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formulaire,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Semantics(
                  button: true,
                  label: l10n.ajouterPhoto,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _choisirPhoto,
                    child: Ink(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _nouvellePhoto != null
                            ? Image.memory(_nouvellePhoto!, fit: BoxFit.cover)
                            : photoUrl != null
                            ? Image.network(photoUrl, fit: BoxFit.cover)
                            : const Center(
                                child: ExcludeSemantics(
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 36,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nom,
                decoration: InputDecoration(labelText: l10n.champNomProduit),
                textCapitalization: TextCapitalization.sentences,
                maxLength: 120,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.champObligatoire
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(labelText: l10n.champDescription),
                maxLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _prix,
                      decoration: InputDecoration(labelText: l10n.champPrix),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => lirePrix(v ?? '') == null
                          ? l10n.validationPrix
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<Devise>(
                      initialValue: devise,
                      decoration: InputDecoration(labelText: l10n.champDevise),
                      items: [
                        for (final d in Devise.values)
                          DropdownMenuItem(value: d, child: Text(d.name)),
                      ],
                      onChanged: (d) => setState(() => _devise = d),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _publie,
                onChanged: (v) => setState(() => _publie = v),
                title: Text(l10n.produitVisible),
                subtitle: Text(l10n.produitVisibleAide),
                contentPadding: EdgeInsets.zero,
              ),
              if (_erreur != null) ...[
                const SizedBox(height: 8),
                Text(
                  _erreur!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _occupe ? null : () => _enregistrer(devise),
                child: _occupe
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: l10n.chargement,
                        ),
                      )
                    : Text(l10n.enregistrer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
