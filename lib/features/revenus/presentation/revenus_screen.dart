import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../commerce/data/pays.dart';
import '../../commerce/presentation/libelles.dart';
import '../../explorer/explorer_providers.dart';
import '../data/revenus.dart';
import '../revenus_providers.dart';

/// Revenus de Harambee par mois et par pays (administrateurs).
class RevenusScreen extends ConsumerStatefulWidget {
  const RevenusScreen({super.key});

  @override
  ConsumerState<RevenusScreen> createState() => _RevenusScreenState();
}

class _RevenusScreenState extends ConsumerState<RevenusScreen> {
  late int _annee = ref.read(horlogeProvider)().year;
  String? _pays;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toString();
    final commandes = ref.watch(commandesAnneeProvider(_annee));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.revenus)),
      body: commandes.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
        ),
        error: (_, _) => EtatVide(
          icone: Icons.wifi_off,
          titre: l10n.erreurReseau,
          texte: '',
        ),
        data: (liste) {
          final paysPresents = {
            for (final c in liste)
              if (c.pays != null) c.pays!,
          }.toList()..sort();
          final revenus = revenusParMois(liste, pays: _pays).entries.toList()
            ..sort(
              (a, b) => (b.key.$1.annee * 100 + b.key.$1.mois).compareTo(
                a.key.$1.annee * 100 + a.key.$1.mois,
              ),
            );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.anneePrecedente,
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _annee--),
                  ),
                  Text('$_annee', style: theme.textTheme.titleLarge),
                  IconButton(
                    tooltip: l10n.anneeSuivante,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _annee++),
                  ),
                  const Spacer(),
                  DropdownButton<String?>(
                    value: _pays,
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(l10n.tousLesPays),
                      ),
                      for (final p in paysPresents)
                        DropdownMenuItem(
                          value: p,
                          child: Text(Pays.depuisCode(p)?.nom(langue) ?? p),
                        ),
                    ],
                    onChanged: (p) => setState(() => _pays = p),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (revenus.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l10n.aucunRevenu,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              for (final e in revenus)
                _CarteMois(
                  titre: DateFormat.yMMMM(langue)
                      .format(DateTime(e.key.$1.annee, e.key.$1.mois)),
                  devise: e.key.$2,
                  revenus: e.value,
                  aFacturer: duParCommerce([
                    for (final c in liste)
                      if (_pays == null || c.pays == _pays) c,
                  ], e.key.$1),
                  locale: locale,
                ),
              const SizedBox(height: 8),
              Text(
                l10n.revenusAbonnementsBientot,
                style: theme.textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CarteMois extends StatelessWidget {
  const _CarteMois({
    required this.titre,
    required this.devise,
    required this.revenus,
    required this.aFacturer,
    required this.locale,
  });

  final String titre;
  final Devise devise;
  final RevenusMois revenus;
  final Map<(String, String, Devise), num> aFacturer;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    String prix(num v) => formaterPrix(v, devise, locale);
    Widget ligne(String libelle, String montant, {bool gras = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(child: Text(libelle)),
              Text(
                montant,
                style: gras
                    ? theme.textTheme.titleMedium
                    : theme.textTheme.bodyLarge,
              ),
            ],
          ),
        );
    final factures = [
      for (final e in aFacturer.entries)
        if (e.key.$3 == devise) e,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(titre, style: theme.textTheme.titleMedium),
        subtitle: Text(
          '${l10n.nCommandes(revenus.nb)} · ${prix(revenus.total)}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ligne(l10n.commissions, prix(revenus.commissions)),
          ligne(l10n.fraisService, prix(revenus.fraisService)),
          ligne(
            l10n.ecartFraisPaiement,
            prix(revenus.fraisPaiementRetenus - revenus.fraisPaiementReels),
          ),
          ligne(l10n.totalRevenus, prix(revenus.total), gras: true),
          if (factures.isNotEmpty) ...[
            const Divider(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.aFacturerEspeces,
                style: theme.textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 4),
            for (final f in factures) ligne(f.key.$2, prix(f.value)),
          ],
        ],
      ),
    );
  }
}
