import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/avis.dart';
import '../../../shared/models/commerce.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/horaires.dart';
import '../../../shared/models/signalement.dart';
import '../../../shared/widgets/dialogue_texte.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../../shared/widgets/label_chip.dart';
import '../../auth/auth_providers.dart';
import '../../commerce/commerce_providers.dart';
import '../../commerce/data/pays.dart';
import '../../commerce/presentation/libelles.dart';
import '../../commandes/commandes_providers.dart';
import '../../commandes/presentation/panier_screen.dart';
import '../../messages/messagerie_providers.dart';
import '../explorer_providers.dart';
import 'carte_commerce.dart';

/// Fiche d'un commerce telle que la voient les clients.
class FichePubliqueScreen extends ConsumerWidget {
  const FichePubliqueScreen({super.key, required this.commerceId});

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
            body: EtatVide(
              icone: Icons.storefront_outlined,
              titre: l10n.commerceIntrouvable,
              texte: '',
            ),
          ),
          data: (c) => c == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: EtatVide(
                    icone: Icons.storefront_outlined,
                    titre: l10n.commerceIntrouvable,
                    texte: '',
                  ),
                )
              : _Fiche(commerce: c),
        );
  }
}

/// Envoie vers l'écran de connexion si personne n'est connecté.
/// Renvoie l'uid de l'utilisateur connecté, sinon null.
String? _exigerConnexion(BuildContext context, WidgetRef ref) {
  final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) context.push(Routes.bienvenue);
  return uid;
}

Future<void> _ouvrirConversation(
  BuildContext context,
  WidgetRef ref,
  Commerce commerce,
) async {
  final uid = _exigerConnexion(context, ref);
  if (uid == null) return;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final nom =
      ref.read(profilProvider).value?.nom ??
      ref.read(utilisateurFirebaseProvider).value?.displayName ??
      '';
  try {
    final id = await ref
        .read(messagerieRepositoryProvider)
        .ouvrir(commerce: commerce, clientId: uid, clientNom: nom);
    router.go(Routes.conversation(id));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.erreurReseau)));
  }
}

Future<void> _signaler(
  BuildContext context,
  WidgetRef ref, {
  required CibleSignalement cible,
  required String cibleId,
}) async {
  final l10n = AppLocalizations.of(context);
  final uid = _exigerConnexion(context, ref);
  if (uid == null) return;
  final motif = await demanderTexte(
    context,
    titre: l10n.signaler,
    libelle: l10n.motif,
    aide: l10n.signalerAide,
  );
  if (motif == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref
        .read(explorerRepositoryProvider)
        .signaler(
          Signalement(
            auteur: uid,
            cible: cible,
            cibleId: cibleId,
            motif: motif,
          ),
        );
    messenger.showSnackBar(SnackBar(content: Text(l10n.signalementEnvoye)));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.erreurEnregistrement)));
  }
}

class _Fiche extends ConsumerWidget {
  const _Fiche({required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final favori = ref.watch(favorisIdsProvider).contains(commerce.id);

    final panier = ref.watch(paniersProvider)[commerce.id];
    final locale = Localizations.localeOf(context).toString();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        bottomNavigationBar: panier == null || panier.estVide
            ? null
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '${GoRouterState.of(context).uri.path}/panier',
                    ),
                    icon: const Icon(Icons.shopping_basket_outlined),
                    label: Text(
                      l10n.voirPanier(
                        panier.nbArticles,
                        formaterPrix(
                          panier.sousTotal,
                          commerce.commande?.devise ?? commerce.devise,
                          locale,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              pinned: true,
              title: Text(commerce.nom),
              actions: [
                IconButton(
                  tooltip: favori ? l10n.retirerFavori : l10n.ajouterFavori,
                  isSelected: favori,
                  icon: const Icon(Icons.favorite_border),
                  selectedIcon: Icon(
                    Icons.favorite,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () {
                    final uid = _exigerConnexion(context, ref);
                    if (uid == null) return;
                    ref
                        .read(explorerRepositoryProvider)
                        .definirFavori(uid, commerce.id, !favori);
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: l10n.actions,
                  onSelected: (_) => _signaler(
                    context,
                    ref,
                    cible: CibleSignalement.commerce,
                    cibleId: commerce.id,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'signaler',
                      child: Text(l10n.signaler),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(child: _EnTete(commerce: commerce)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _OngletsDelegate(
                TabBar(
                  tabs: [
                    Tab(text: l10n.ongletProduits),
                    Tab(text: l10n.ongletAvis),
                    Tab(text: l10n.ongletInfos),
                  ],
                ),
                Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _OngletProduits(commerce: commerce),
              _OngletAvis(commerce: commerce),
              _OngletInfos(commerce: commerce),
            ],
          ),
        ),
      ),
    );
  }
}

class _OngletsDelegate extends SliverPersistentHeaderDelegate {
  _OngletsDelegate(this.onglets, this.fond);

  final TabBar onglets;
  final Color fond;

  @override
  double get minExtent => onglets.preferredSize.height;
  @override
  double get maxExtent => onglets.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      ColoredBox(color: fond, child: onglets);

  @override
  bool shouldRebuild(_OngletsDelegate ancien) =>
      ancien.onglets != onglets || ancien.fond != fond;
}

class _EnTete extends ConsumerStatefulWidget {
  const _EnTete({required this.commerce});

  final Commerce commerce;

  @override
  ConsumerState<_EnTete> createState() => _EnTeteState();
}

class _EnTeteState extends ConsumerState<_EnTete> {
  int _photo = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final c = widget.commerce;
    final lanceur = ref.read(lanceurProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (c.photos.isNotEmpty)
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: c.photos.length,
                  onPageChanged: (i) => setState(() => _photo = i),
                  itemBuilder: (_, i) => Image.network(
                    c.photos[i],
                    fit: BoxFit.cover,
                    cacheWidth: 1000,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
                ),
                if (c.photos.length > 1)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < c.photos.length; i++)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: i == _photo ? 1 : 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.nom, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                '${l10n.categorie(c.categorie)} · ${c.ville}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const BadgeVerifie(),
                  if (c.labelAfricain) const LabelChip(TypeLabel.africain),
                  if (c.labelChretien) const LabelChip(TypeLabel.chretien),
                  if (c.nbAvis > 0) NoteEtoiles(commerce: c),
                ],
              ),
              if (c.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(c.description, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed:
                          ref.watch(utilisateurFirebaseProvider).value?.uid ==
                              c.proprietaire
                          ? null
                          : () => _ouvrirConversation(context, ref, c),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: Text(l10n.envoyerMessage),
                    ),
                  ),
                  if (c.telephone != null) ...[
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: l10n.appeler,
                      icon: const Icon(Icons.phone_outlined),
                      onPressed: () => lanceur.appeler(c.telephone!),
                    ),
                  ],
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: l10n.itineraire,
                    icon: const Icon(Icons.directions_outlined),
                    onPressed: () => lanceur.itineraire(
                      geo: c.geo,
                      adresse: '${c.adresse}, ${c.ville}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OngletProduits extends ConsumerWidget {
  const _OngletProduits({required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final peutCommander =
        commerce.commandeOuverte && uid != commerce.proprietaire;
    final panier = ref.watch(paniersProvider)[commerce.id];
    return ref
        .watch(produitsPubliesProvider(commerce.id))
        .when(
          loading: () => Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
          ),
          error: (_, _) => EtatVide(
            icone: Icons.wifi_off,
            titre: l10n.erreurReseau,
            texte: '',
          ),
          data: (produits) => produits.isEmpty
              ? EtatVide(
                  icone: Icons.inventory_2_outlined,
                  titre: l10n.aucunProduitPublic,
                  texte: '',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: produits.length,
                  separatorBuilder: (_, _) => const Divider(height: 24),
                  itemBuilder: (_, i) {
                    final p = produits[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.nom, style: theme.textTheme.titleMedium),
                              if (p.description.isNotEmpty)
                                Text(
                                  p.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                formaterPrix(p.prix, p.devise, locale),
                                style: theme.textTheme.titleSmall,
                              ),
                              if (p.enRupture)
                                Text(
                                  l10n.badgeRupture,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                )
                              else if (peutCommander)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: AjoutPanier(
                                    quantite: panier?.quantite(p.id) ?? 0,
                                    onChanged: (q) => ref
                                        .read(paniersProvider.notifier)
                                        .definir(commerce, p, q),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (p.photoUrl != null) ...[
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              p.photoUrl!,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              cacheWidth: 264,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 88,
                                height: 88,
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
        );
  }
}

class _OngletAvis extends ConsumerWidget {
  const _OngletAvis({required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    final estProprietaire = uid == commerce.proprietaire;
    final avis = ref.watch(avisProvider(commerce.id));
    final liste = avis.value ?? const <Avis>[];
    final monAvis = liste.where((a) => a.auteur == uid).firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!estProprietaire)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: monAvis == null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.donnerAvisTitre,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: () {
                            if (_exigerConnexion(context, ref) == null) return;
                            _ouvrirFormulaireAvis(context, ref, commerce, null);
                          },
                          child: Text(l10n.donnerAvis),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.monAvis, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _Etoiles(note: monAvis.note),
                        if (monAvis.texte.isNotEmpty) Text(monAvis.texte),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => _ouvrirFormulaireAvis(
                            context,
                            ref,
                            commerce,
                            monAvis,
                          ),
                          child: Text(l10n.modifierMonAvis),
                        ),
                      ],
                    ),
            ),
          ),
        const SizedBox(height: 8),
        if (avis.isLoading)
          Center(
            child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
          )
        else if (liste.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.aucunAvis,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final a in liste) ...[
            _TuileAvis(commerce: commerce, avis: a, estMoi: a.auteur == uid),
            const Divider(height: 24),
          ],
      ],
    );
  }
}

class _TuileAvis extends ConsumerWidget {
  const _TuileAvis({
    required this.commerce,
    required this.avis,
    required this.estMoi,
  });

  final Commerce commerce;
  final Avis avis;
  final bool estMoi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                avis.auteurNom.isEmpty ? l10n.anonyme : avis.auteurNom,
                style: theme.textTheme.titleSmall,
              ),
              Row(
                children: [
                  _Etoiles(note: avis.note),
                  if (avis.createdAt != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd(langue).format(avis.createdAt!),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
              if (avis.texte.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(avis.texte),
              ],
            ],
          ),
        ),
        if (!estMoi)
          PopupMenuButton<String>(
            tooltip: l10n.actions,
            onSelected: (_) => _signaler(
              context,
              ref,
              cible: CibleSignalement.avis,
              cibleId: 'commerces/${commerce.id}/avis/${avis.auteur}',
            ),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'signaler', child: Text(l10n.signaler)),
            ],
          ),
      ],
    );
  }
}

class _Etoiles extends StatelessWidget {
  const _Etoiles({required this.note});

  final int note;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).nEtoiles(note),
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= note ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: const Color(0xFFE0A100),
          ),
      ],
    ),
  );
}

Future<void> _ouvrirFormulaireAvis(
  BuildContext context,
  WidgetRef ref,
  Commerce commerce,
  Avis? existant,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _FormulaireAvis(commerce: commerce, existant: existant),
);

class _FormulaireAvis extends ConsumerStatefulWidget {
  const _FormulaireAvis({required this.commerce, this.existant});

  final Commerce commerce;
  final Avis? existant;

  @override
  ConsumerState<_FormulaireAvis> createState() => _FormulaireAvisState();
}

class _FormulaireAvisState extends ConsumerState<_FormulaireAvis> {
  late int _note = widget.existant?.note ?? 0;
  late final _texte = TextEditingController(text: widget.existant?.texte);
  bool _occupe = false;
  String? _erreur;

  @override
  void dispose() {
    _texte.dispose();
    super.dispose();
  }

  Future<void> _publier() async {
    final l10n = AppLocalizations.of(context);
    if (_note == 0) {
      setState(() => _erreur = l10n.choisirNote);
      return;
    }
    final uid = ref.read(utilisateurFirebaseProvider).value?.uid;
    if (uid == null) return;
    final nom =
        ref.read(profilProvider).value?.nom ??
        ref.read(utilisateurFirebaseProvider).value?.displayName ??
        '';
    setState(() {
      _occupe = true;
      _erreur = null;
    });
    try {
      await ref
          .read(explorerRepositoryProvider)
          .enregistrerAvis(
            widget.commerce.id,
            uid: uid,
            auteurNom: nom,
            note: _note,
            texte: _texte.text,
          );
      if (mounted) Navigator.pop(context);
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existant == null ? l10n.donnerAvis : l10n.modifierMonAvis,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  tooltip: l10n.nEtoiles(i),
                  iconSize: 36,
                  icon: Icon(
                    i <= _note
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFE0A100),
                  ),
                  onPressed: () => setState(() {
                    _note = i;
                    _erreur = null;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _texte,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(labelText: l10n.votreAvis),
          ),
          if (_erreur != null)
            Text(_erreur!, style: TextStyle(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _occupe ? null : _publier,
            child: Text(l10n.publierAvis),
          ),
        ],
      ),
    );
  }
}

class _OngletInfos extends ConsumerWidget {
  const _OngletInfos({required this.commerce});

  final Commerce commerce;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final maintenant = ref.watch(horlogeProvider)();
    final aujourdhui = joursSemaine[maintenant.weekday - 1];
    final c = commerce;
    final pays = Pays.depuisCode(c.pays)?.nom(langue) ?? c.pays;
    final aDesHoraires = c.horaires.values.any((p) => p.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.place_outlined),
          title: Text(c.adresse),
          subtitle: Text('${c.ville}, $pays'),
        ),
        if (c.telephone != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.phone_outlined),
            title: Text(c.telephone!),
            onTap: () => ref.read(lanceurProvider).appeler(c.telephone!),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(l10n.champHoraires, style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            if (aDesHoraires)
              Text(
                estOuvert(c.horaires, maintenant)
                    ? l10n.ouvert
                    : l10n.fermeMaintenant,
                style: TextStyle(
                  color: estOuvert(c.horaires, maintenant)
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (!aDesHoraires)
          Text(l10n.horairesNonRenseignes)
        else
          for (final (cle, jour) in l10n.jours)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      jour,
                      style: cle == aujourdhui
                          ? const TextStyle(fontWeight: FontWeight.w700)
                          : null,
                    ),
                  ),
                  Text(
                    (c.horaires[cle]?.isNotEmpty ?? false)
                        ? c.horaires[cle]!.join(', ')
                        : l10n.ferme,
                    style: cle == aujourdhui
                        ? const TextStyle(fontWeight: FontWeight.w700)
                        : null,
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
