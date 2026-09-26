import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/models/tarifs.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../../commerce/commerce_providers.dart';
import '../../commerce/data/localisation_service.dart';
import '../../commerce/presentation/libelles.dart';
import '../commandes_providers.dart';
import '../data/commandes_repository.dart';
import '../data/panier.dart';

/// Panier d'un commerce : quantités, mode, adresse, paiement, total.
class PanierScreen extends ConsumerStatefulWidget {
  const PanierScreen({super.key, required this.commerceId});

  final String commerceId;

  @override
  ConsumerState<PanierScreen> createState() => _PanierScreenState();
}

class _PanierScreenState extends ConsumerState<PanierScreen> {
  final _formulaire = GlobalKey<FormState>();
  final _adresse = TextEditingController();
  final _instructions = TextEditingController();
  final _telephone = TextEditingController();
  ModeCommande? _mode;
  MethodePaiement? _methode;
  GeoPoint? _position;
  bool _localisation = false;
  bool _envoi = false;
  String? _erreur;

  @override
  void dispose() {
    _adresse.dispose();
    _instructions.dispose();
    _telephone.dispose();
    super.dispose();
  }

  Future<void> _localiser() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _localisation = true);
    try {
      final p = await ref.read(localisationServiceProvider).positionActuelle();
      setState(() => _position = p);
    } on ExceptionLocalisation {
      setState(() => _erreur = l10n.localisationIndisponible);
    } finally {
      if (mounted) setState(() => _localisation = false);
    }
  }

  String _messageErreur(
    AppLocalizations l10n,
    ErreurCommande e,
    String locale,
    Panier panier,
  ) => switch (e.code) {
    'minimum-non-atteint' => l10n.encoreXPourMinimum(
      formaterPrix(e.manque ?? 0, panier.commerce.commande!.devise, locale),
    ),
    'produit-indisponible' => l10n.erreurProduitIndisponible,
    'hors-zone' => l10n.erreurHorsZone,
    'commande-inactive' || 'mode-indisponible' => l10n.erreurCommandeFermee,
    'especes-refusees' ||
    'carte-indisponible' => l10n.erreurPaiementIndisponible,
    'tarifs-manquants' => l10n.erreurTarifsManquants,
    'reseau' => l10n.erreurReseau,
    _ => l10n.erreurInconnue,
  };

  Future<void> _commander(
    Panier panier,
    ModeCommande mode,
    MethodePaiement methode,
  ) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    setState(() => _erreur = null);
    if (ref.read(utilisateurFirebaseProvider).value == null) {
      context.push(Routes.bienvenue);
      return;
    }
    if (!_formulaire.currentState!.validate()) return;
    if (mode == ModeCommande.livraison && _position == null) {
      setState(() => _erreur = l10n.positionLivraisonRequise);
      return;
    }
    setState(() => _envoi = true);
    try {
      final id = await ref
          .read(fonctionsCommandeProvider)
          .creer(
            DemandeCommande(
              commerceId: panier.commerce.id,
              lignes: {
                for (final e in panier.lignes.entries) e.key: e.value.$2,
              },
              mode: mode,
              methode: methode,
              telephone: _telephone.text.trim(),
              adresseTexte: _adresse.text.trim(),
              adresseGeo: _position,
              instructions: _instructions.text.trim(),
            ),
          );
      ref.read(paniersProvider.notifier).vider(panier.commerce.id);
      if (mounted) context.go(Routes.commande(id));
    } on ErreurCommande catch (e) {
      if (mounted) {
        setState(() => _erreur = _messageErreur(l10n, e, locale, panier));
      }
    } catch (_) {
      if (mounted) setState(() => _erreur = l10n.erreurInconnue);
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final panier = ref.watch(paniersProvider)[widget.commerceId];
    final commerce = ref.watch(commerceProvider(widget.commerceId)).value;
    final tarifs = ref.watch(tarifsProvider).value ?? const Tarifs();

    if (panier == null || panier.estVide || commerce == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.panier)),
        body: EtatVide(
          icone: Icons.shopping_basket_outlined,
          titre: l10n.panierVide,
          texte: '',
        ),
      );
    }
    final reglages = commerce.commande ?? const ReglagesCommande();
    // « À emporter » d'abord : pas d'adresse à saisir.
    final modes = [
      for (final m in const [ModeCommande.emporter, ModeCommande.livraison])
        if (reglages.modes.contains(m)) m,
    ];
    final mode = modes.contains(_mode) ? _mode! : modes.first;
    final methodes = [
      if (commerce.paiementCarteActif) MethodePaiement.carte,
      if (reglages.especesAcceptees) MethodePaiement.especes,
    ];
    final methode = methodes.contains(_methode)
        ? _methode
        : (methodes.isEmpty ? null : methodes.first);
    final panierAJour = Panier(commerce: commerce, lignes: panier.lignes);
    final estimation = EstimationPanier.calculer(panierAJour, mode, tarifs);
    String prix(num v) => formaterPrix(v, reglages.devise, locale);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.panierDe(commerce.nom))),
      body: SafeArea(
        child: Form(
          key: _formulaire,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (produit, quantite) in panier.lignes.values)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(produit.nom),
                  subtitle: Text(prix(produit.prix * quantite)),
                  trailing: _Quantite(
                    quantite: quantite,
                    onChanged: (q) => ref
                        .read(paniersProvider.notifier)
                        .definir(commerce, produit, q),
                  ),
                ),
              const Divider(height: 32),
              if (modes.length > 1)
                SegmentedButton<ModeCommande>(
                  segments: [
                    for (final m in modes)
                      ButtonSegment(
                        value: m,
                        label: Text(
                          m == ModeCommande.livraison
                              ? l10n.modeLivraison
                              : l10n.modeEmporter,
                        ),
                      ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                )
              else
                Text(
                  mode == ModeCommande.livraison
                      ? l10n.modeLivraison
                      : l10n.modeEmporter,
                  style: theme.textTheme.titleMedium,
                ),
              const SizedBox(height: 16),
              if (mode == ModeCommande.livraison) ...[
                TextFormField(
                  controller: _adresse,
                  decoration: InputDecoration(labelText: l10n.adresseLivraison),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.champObligatoire
                      : null,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _position == null
                        ? Icons.location_searching
                        : Icons.location_on,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    _position == null
                        ? l10n.positionLivraison
                        : l10n.positionEnregistree,
                  ),
                  subtitle: Text(
                    l10n.positionLivraisonAide(
                      reglages.rayonLivraisonKm.toString(),
                    ),
                  ),
                  onTap: _localisation ? null : _localiser,
                ),
                TextFormField(
                  controller: _instructions,
                  decoration: InputDecoration(
                    labelText: l10n.instructionsLivraison,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _telephone,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                decoration: InputDecoration(
                  labelText: l10n.champTelephone,
                  helperText: l10n.telephoneCommandeAide,
                ),
                validator: (v) => (v == null || v.trim().length < 6)
                    ? l10n.champObligatoire
                    : null,
              ),
              const SizedBox(height: 16),
              Text(l10n.paiement, style: theme.textTheme.titleMedium),
              if (methodes.isEmpty)
                Text(l10n.erreurPaiementIndisponible)
              else
                RadioGroup<MethodePaiement>(
                  groupValue: methode,
                  onChanged: (m) => setState(() => _methode = m),
                  child: Column(
                    children: [
                      for (final m in methodes)
                        RadioListTile<MethodePaiement>(
                          value: m,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            m == MethodePaiement.carte
                                ? l10n.paiementCarte
                                : (mode == ModeCommande.livraison
                                      ? l10n.especesLivraison
                                      : l10n.especesRetrait),
                          ),
                        ),
                    ],
                  ),
                ),
              const Divider(height: 32),
              _LigneMontant(l10n.sousTotal, prix(estimation.sousTotal)),
              if (mode == ModeCommande.livraison)
                _LigneMontant(
                  l10n.fraisLivraison,
                  estimation.fraisLivraison == 0
                      ? l10n.offerte
                      : prix(estimation.fraisLivraison),
                ),
              _LigneMontant(
                l10n.fraisService,
                prix(estimation.fraisService),
                aide: l10n.fraisServiceAide,
              ),
              const SizedBox(height: 4),
              _LigneMontant(l10n.total, prix(estimation.total), gras: true),
              const SizedBox(height: 16),
              if (!estimation.minimumAtteint)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.encoreXPourMinimum(prix(estimation.manquePourMinimum)),
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_erreur != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _erreur!,
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              FilledButton(
                onPressed:
                    _envoi || !estimation.minimumAtteint || methode == null
                    ? null
                    : () => _commander(panierAJour, mode, methode),
                child: Text(l10n.commanderMontant(prix(estimation.total))),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.montantConfirmeServeur,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LigneMontant extends StatelessWidget {
  const _LigneMontant(
    this.libelle,
    this.montant, {
    this.aide,
    this.gras = false,
  });

  final String libelle;
  final String montant;
  final String? aide;
  final bool gras;

  @override
  Widget build(BuildContext context) {
    final style = gras
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(libelle, style: style),
          if (aide != null)
            Tooltip(
              message: aide!,
              triggerMode: TooltipTriggerMode.tap,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.info_outline, size: 18),
              ),
            ),
          const Spacer(),
          Text(montant, style: style),
        ],
      ),
    );
  }
}

/// Boutons − / quantité / + (zones tactiles de 48 px).
class _Quantite extends StatelessWidget {
  const _Quantite({required this.quantite, required this.onChanged});

  final int quantite;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: quantite == 1 ? l10n.retirer : l10n.diminuer,
          icon: Icon(quantite == 1 ? Icons.delete_outline : Icons.remove),
          onPressed: () => onChanged(quantite - 1),
        ),
        Text('$quantite', style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          tooltip: l10n.augmenter,
          icon: const Icon(Icons.add),
          onPressed: quantite >= 99 ? null : () => onChanged(quantite + 1),
        ),
      ],
    );
  }
}

/// Contrôle d'ajout au panier affiché sur chaque produit de la fiche.
class AjoutPanier extends StatelessWidget {
  const AjoutPanier({
    super.key,
    required this.quantite,
    required this.onChanged,
  });

  final int quantite;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => quantite == 0
      ? FilledButton.tonal(
          onPressed: () => onChanged(1),
          child: Text(AppLocalizations.of(context).ajouterAuPanier),
        )
      : _Quantite(quantite: quantite, onChanged: onChanged);
}
