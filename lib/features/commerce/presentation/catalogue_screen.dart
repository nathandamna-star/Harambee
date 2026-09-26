import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/produit.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../commerce_providers.dart';
import 'libelles.dart';

/// Catalogue d'un commerce, géré par son propriétaire.
class CatalogueScreen extends ConsumerWidget {
  const CatalogueScreen({super.key, required this.commerceId});

  final String commerceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final produits = ref.watch(produitsProvider(commerceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogue)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.nouveauProduit(commerceId)),
        icon: const Icon(Icons.add),
        label: Text(l10n.ajouterProduit),
      ),
      body: produits.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
        ),
        error: (_, _) => EtatVide(
          icone: Icons.wifi_off,
          titre: l10n.erreurReseau,
          texte: '',
        ),
        data: (liste) => liste.isEmpty
            ? EtatVide(
                icone: Icons.inventory_2_outlined,
                titre: l10n.catalogueVideTitre,
                texte: l10n.catalogueVideTexte,
              )
            : _ListeProduits(commerceId: commerceId, produits: liste),
      ),
    );
  }
}

class _ListeProduits extends ConsumerStatefulWidget {
  const _ListeProduits({required this.commerceId, required this.produits});

  final String commerceId;
  final List<Produit> produits;

  @override
  ConsumerState<_ListeProduits> createState() => _ListeProduitsState();
}

class _ListeProduitsState extends ConsumerState<_ListeProduits> {
  // Copie locale pour un réordonnancement immédiat à l'écran.
  late List<Produit> _produits = widget.produits;

  @override
  void didUpdateWidget(covariant _ListeProduits ancien) {
    super.didUpdateWidget(ancien);
    _produits = widget.produits;
  }

  void _deplacer(int de, int vers) {
    setState(() {
      _produits = [..._produits];
      _produits.insert(vers, _produits.removeAt(de));
    });
    ref.read(commerceRepositoryProvider).reordonner(widget.commerceId, [
      for (final p in _produits) p.id,
    ]);
  }

  Future<void> _supprimer(Produit p) async {
    final l10n = AppLocalizations.of(context);
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supprimerProduitTitre),
        content: Text(l10n.supprimerProduitTexte(p.nom)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.annuler),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.supprimer),
          ),
        ],
      ),
    );
    if (confirme == true) {
      await ref
          .read(commerceRepositoryProvider)
          .supprimerProduit(widget.commerceId, p);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final repo = ref.read(commerceRepositoryProvider);
    final theme = Theme.of(context);

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: _produits.length,
      onReorderItem: _deplacer,
      itemBuilder: (context, i) {
        final p = _produits[i];
        return Card(
          key: ValueKey(p.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.only(left: 12, right: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox.square(
                dimension: 48,
                child: p.photoUrl == null
                    ? ColoredBox(
                        color: theme.colorScheme.surface,
                        child: const Icon(Icons.image_outlined),
                      )
                    : Image.network(
                        p.photoUrl!,
                        fit: BoxFit.cover,
                        cacheWidth: 150,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image_outlined),
                      ),
              ),
            ),
            title: Text(p.nom),
            subtitle: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(formaterPrix(p.prix, p.devise, locale)),
                if (!p.publie) _Badge(l10n.badgeMasque),
                if (p.enRupture) _Badge(l10n.badgeRupture),
              ],
            ),
            onTap: () => context.push(
              Routes.modifierProduit(widget.commerceId, p.id),
              extra: p,
            ),
            trailing: PopupMenuButton<String>(
              tooltip: l10n.actions,
              onSelected: (action) => switch (action) {
                'modifier' => context.push(
                  Routes.modifierProduit(widget.commerceId, p.id),
                  extra: p,
                ),
                'publie' => repo.definirPublie(
                  widget.commerceId,
                  p.id,
                  !p.publie,
                ),
                'rupture' => repo.definirRupture(
                  widget.commerceId,
                  p.id,
                  !p.enRupture,
                ),
                _ => _supprimer(p),
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'modifier', child: Text(l10n.modifier)),
                PopupMenuItem(
                  value: 'publie',
                  child: Text(p.publie ? l10n.masquer : l10n.afficher),
                ),
                PopupMenuItem(
                  value: 'rupture',
                  child: Text(
                    p.enRupture ? l10n.marquerDisponible : l10n.marquerRupture,
                  ),
                ),
                PopupMenuItem(value: 'supprimer', child: Text(l10n.supprimer)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.texte);
  final String texte;

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: couleurs.outline.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(texte, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
