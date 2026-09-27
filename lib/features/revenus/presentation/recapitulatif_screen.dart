import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../commandes/commandes_providers.dart';
import '../../commerce/presentation/libelles.dart';
import '../data/revenus.dart';
import '../revenus_providers.dart';

/// Récapitulatif mensuel du commerçant, téléchargeable en CSV.
class RecapitulatifScreen extends ConsumerStatefulWidget {
  const RecapitulatifScreen({super.key});

  @override
  ConsumerState<RecapitulatifScreen> createState() =>
      _RecapitulatifScreenState();
}

class _RecapitulatifScreenState extends ConsumerState<RecapitulatifScreen> {
  (Mois, Devise)? _choix;

  Future<void> _telecharger(Mois mois, RecapMensuel recap) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final csv = csvRecap(recap, [
      l10n.csvDate,
      l10n.csvNumero,
      l10n.csvClient,
      l10n.paiement,
      l10n.payeParClient,
      l10n.fraisLivraison,
      l10n.fraisService,
      l10n.commission,
      l10n.fraisPaiement,
      l10n.montantNet,
      l10n.champDevise,
    ]);
    try {
      await ref
          .read(partageFichierProvider)
          .partager(
            nom:
                'harambee-${mois.annee}-${mois.mois.toString().padLeft(2, '0')}.csv',
            contenu: csv,
            typeMime: 'text/csv',
          );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.erreurInconnue)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recapitulatifMensuel)),
      body: ref
          .watch(commandesProProvider)
          .when(
            loading: () => Center(
              child: CircularProgressIndicator(semanticsLabel: l10n.chargement),
            ),
            error: (_, _) => EtatVide(
              icone: Icons.wifi_off,
              titre: l10n.erreurReseau,
              texte: '',
            ),
            data: (commandes) {
              final recaps = recapsMensuels(commandes);
              if (recaps.isEmpty) {
                return EtatVide(
                  icone: Icons.summarize_outlined,
                  titre: l10n.aucunRecap,
                  texte: l10n.aucunRecapAide,
                );
              }
              final cles = recaps.keys.toList()
                ..sort(
                  (a, b) => (b.$1.annee * 100 + b.$1.mois).compareTo(
                    a.$1.annee * 100 + a.$1.mois,
                  ),
                );
              final choix = cles.contains(_choix) ? _choix! : cles.first;
              final r = recaps[choix]!;
              String prix(num v) => formaterPrix(v, r.devise, locale);
              Widget ligne(
                String libelle,
                String montant, {
                bool gras = false,
              }) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
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

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in cles)
                        ChoiceChip(
                          label: Text(
                            '${DateFormat.yMMM(langue).format(DateTime(c.$1.annee, c.$1.mois))}'
                            '${cles.where((x) => x.$1 == c.$1).length > 1 ? ' · ${c.$2.name}' : ''}',
                          ),
                          selected: c == choix,
                          onSelected: (_) => setState(() => _choix = c),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ligne(l10n.nbCommandesTerminees, '${r.nb}'),
                          ligne(l10n.payeParClient, prix(r.ventes)),
                          ligne(l10n.dontLivraison, prix(r.fraisLivraison)),
                          ligne(
                            l10n.fraisServicePlateforme,
                            '− ${prix(r.fraisService)}',
                          ),
                          ligne(l10n.commission, '− ${prix(r.commission)}'),
                          ligne(
                            l10n.fraisPaiement,
                            '− ${prix(r.fraisPaiement)}',
                          ),
                          const Divider(height: 24),
                          ligne(l10n.montantNet, prix(r.net), gras: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          ligne(l10n.verseParStripe, prix(r.verseCarte)),
                          ligne(l10n.encaisseEspeces, prix(r.ventesEspeces)),
                          if (r.duEspeces > 0) ...[
                            const Divider(height: 24),
                            ligne(
                              l10n.duAHarambee,
                              prix(r.duEspeces),
                              gras: true,
                            ),
                            Text(
                              l10n.duAHarambeeAide,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _telecharger(choix.$1, r),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.telechargerCsv),
                  ),
                ],
              );
            },
          ),
    );
  }
}
