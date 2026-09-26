import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../commerce/presentation/libelles.dart';
import '../commandes_providers.dart';
import 'libelles_commande.dart';

/// Commandes du client (« Mes commandes ») ou du commerçant (« Commandes »).
class ListeCommandesScreen extends ConsumerStatefulWidget {
  const ListeCommandesScreen({super.key, required this.pourPro});

  final bool pourPro;

  @override
  ConsumerState<ListeCommandesScreen> createState() =>
      _ListeCommandesScreenState();
}

class _ListeCommandesScreenState extends ConsumerState<ListeCommandesScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = widget.pourPro
        ? commandesProProvider
        : mesCommandesProvider;

    if (widget.pourPro) {
      // Alerte sonore et vibration à l'arrivée d'une nouvelle commande.
      ref.listen(nbNouvellesCommandesProvider, (avant, apres) {
        if (avant != null && apres > avant) {
          SystemSound.play(SystemSoundType.alert);
          HapticFeedback.heavyImpact();
        }
      });
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.pourPro ? l10n.commandes : l10n.mesCommandes),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.enCours),
              Tab(text: l10n.terminees),
            ],
          ),
        ),
        body: ref
            .watch(provider)
            .when(
              loading: () => Center(
                child: CircularProgressIndicator(
                  semanticsLabel: l10n.chargement,
                ),
              ),
              error: (_, _) => EtatVide(
                icone: Icons.wifi_off,
                titre: l10n.erreurReseau,
                texte: '',
              ),
              data: (liste) {
                final enCours = liste
                    .where((c) => !c.statut.estTerminee)
                    .toList();
                final terminees = liste
                    .where((c) => c.statut.estTerminee)
                    .toList();
                return TabBarView(
                  children: [
                    _Liste(commandes: enCours, pourPro: widget.pourPro),
                    _Liste(
                      commandes: terminees,
                      pourPro: widget.pourPro,
                      avecTotal: widget.pourPro,
                    ),
                  ],
                );
              },
            ),
      ),
    );
  }
}

class _Liste extends StatelessWidget {
  const _Liste({
    required this.commandes,
    required this.pourPro,
    this.avecTotal = false,
  });

  final List<Commande> commandes;
  final bool pourPro;
  final bool avecTotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final langue = Localizations.localeOf(context).languageCode;
    if (commandes.isEmpty) {
      return EtatVide(
        icone: Icons.receipt_long_outlined,
        titre: l10n.aucuneCommande,
        texte: pourPro ? l10n.aucuneCommandeProAide : '',
      );
    }

    // Total des ventes livrées ou retirées, par devise.
    final ventes = <String, num>{};
    for (final c in commandes) {
      if (c.statut == StatutCommande.livree ||
          c.statut == StatutCommande.retiree) {
        ventes[c.devise.name] = (ventes[c.devise.name] ?? 0) + c.total;
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (avecTotal && ventes.isNotEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text(l10n.totalVentes),
              subtitle: Text(
                ventes.entries
                    .map(
                      (e) => formaterPrix(
                        e.value,
                        commandes
                            .firstWhere((c) => c.devise.name == e.key)
                            .devise,
                        locale,
                      ),
                    )
                    .join(' · '),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
        for (final c in commandes)
          Card(
            color: pourPro && c.statut == StatutCommande.nouvelle
                ? theme.colorScheme.primary.withValues(alpha: 0.08)
                : null,
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              title: Text(
                '${pourPro ? c.clientNom : c.commerceNom} · ${c.numero}',
                style: pourPro && c.statut == StatutCommande.nouvelle
                    ? const TextStyle(fontWeight: FontWeight.w700)
                    : null,
              ),
              subtitle: Text(
                [
                  l10n.statutCommandeLibelle(c.statut),
                  formaterPrix(c.total, c.devise, locale),
                  if (c.createdAt != null)
                    DateFormat.MMMd(langue).add_Hm().format(c.createdAt!),
                ].join(' · '),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.commande(c.id)),
            ),
          ),
      ],
    );
  }
}
