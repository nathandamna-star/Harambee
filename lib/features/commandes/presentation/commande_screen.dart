import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commande.dart';
import '../../../shared/widgets/dialogue_texte.dart';
import '../../../shared/widgets/etat_vide.dart';
import '../../auth/auth_providers.dart';
import '../../commerce/presentation/libelles.dart';
import '../../explorer/explorer_providers.dart';
import '../commandes_providers.dart';
import '../data/paiement_service.dart';
import 'libelles_commande.dart';

/// Détail et suivi en temps réel d'une commande. Le client peut annuler une
/// commande encore « nouvelle » ; le commerçant la fait avancer.
class CommandeScreen extends ConsumerWidget {
  const CommandeScreen({super.key, required this.commandeId});

  final String commandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
    return ref
        .watch(commandeProvider(commandeId))
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
              icone: Icons.receipt_long_outlined,
              titre: l10n.commandeIntrouvable,
              texte: '',
            ),
          ),
          data: (c) => c == null || uid == null
              ? Scaffold(
                  appBar: AppBar(),
                  body: EtatVide(
                    icone: Icons.receipt_long_outlined,
                    titre: l10n.commandeIntrouvable,
                    texte: '',
                  ),
                )
              : _Detail(commande: c, estPro: c.proId == uid),
        );
  }
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.commande, required this.estPro});

  final Commande commande;
  final bool estPro;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _occupe = false;

  Commande get c => widget.commande;

  Future<void> _changer(StatutCommande statut, {String? motif}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      await ref
          .read(commandesRepositoryProvider)
          .changerStatut(c.id, statut, motif: motif);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.erreurEnregistrement)),
      );
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _payer() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _occupe = true);
    try {
      final secret = await ref
          .read(fonctionsCommandeProvider)
          .secretPaiement(c.id);
      final r = await ref.read(paiementServiceProvider).payer(secret);
      if (r != ResultatPaiement.reussi) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.paiementNonTermine)),
        );
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.erreurReseau)));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  Future<void> _refuser() async {
    final l10n = AppLocalizations.of(context);
    final motif = await demanderTexte(
      context,
      titre: l10n.refuserCommande,
      libelle: l10n.motif,
      aide: l10n.motifRefusCommandeAide,
    );
    if (motif != null) await _changer(StatutCommande.refusee, motif: motif);
  }

  Future<void> _annuler() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.annulerCommandeTitre),
        content: Text(l10n.annulerCommandeTexte),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.non),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.annulerCommande),
          ),
        ],
      ),
    );
    if (ok == true) await _changer(StatutCommande.annulee);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final langue = Localizations.localeOf(context).languageCode;
    String prix(num v) => formaterPrix(v, c.devise, locale);
    final suivant = c.statut.suivant(c.mode);
    final lanceur = ref.read(lanceurProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.commandeNumero(c.numero))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.estPro ? c.clientNom : c.commerceNom,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              [
                c.mode == ModeCommande.livraison
                    ? l10n.modeLivraison
                    : l10n.modeEmporter,
                c.methodePaiement == MethodePaiement.carte
                    ? l10n.paiementCarte
                    : l10n.paiementEspeces,
                if (c.createdAt != null)
                  DateFormat.yMMMd(langue).add_Hm().format(c.createdAt!),
              ].join(' · '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (c.methodePaiement == MethodePaiement.carte) ...[
              const SizedBox(height: 8),
              Text(
                l10n.etatPaiement(switch (c.statutPaiement) {
                  StatutPaiement.enAttente => l10n.paiementEnAttente,
                  StatutPaiement.paye => l10n.paiementPaye,
                  StatutPaiement.rembourse => l10n.paiementRembourse,
                  StatutPaiement.echoue => l10n.paiementEchoue,
                }),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: c.statutPaiement == StatutPaiement.paye
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _Suivi(commande: c),
            if (c.motifRefus != null && c.statut == StatutCommande.refusee) ...[
              const SizedBox(height: 8),
              Text(
                l10n.motifActuel(c.motifRefus!),
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const Divider(height: 32),
            for (final l in c.lignes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('${l.quantite} × ', style: theme.textTheme.titleSmall),
                    Expanded(child: Text(l.nom)),
                    Text(prix(l.total)),
                  ],
                ),
              ),
            const Divider(height: 24),
            _Ligne(l10n.sousTotal, prix(c.sousTotal)),
            if (c.mode == ModeCommande.livraison)
              _Ligne(l10n.fraisLivraison, prix(c.fraisLivraison)),
            _Ligne(l10n.fraisService, prix(c.fraisService)),
            _Ligne(l10n.total, prix(c.total), gras: true),
            if (widget.estPro) ...[
              const Divider(height: 32),
              Text(l10n.pourVotreCommerce, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _Ligne(l10n.payeParClient, prix(c.total)),
              _Ligne(l10n.fraisServicePlateforme, '− ${prix(c.fraisService)}'),
              _Ligne(l10n.commission, '− ${prix(c.commissionPlateforme)}'),
              _Ligne(l10n.fraisPaiement, '− ${prix(c.fraisPaiement)}'),
              _Ligne(l10n.montantNet, prix(c.montantNet), gras: true),
              if (c.methodePaiement == MethodePaiement.especes)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.especesAEncaisser(prix(c.total)),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              const Divider(height: 32),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.phone_outlined),
                title: Text(c.telephoneClient),
                onTap: () => lanceur.appeler(c.telephoneClient),
              ),
              if (c.mode == ModeCommande.livraison)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.place_outlined),
                  title: Text(c.adresseTexte ?? ''),
                  subtitle: (c.instructions?.isNotEmpty ?? false)
                      ? Text(c.instructions!)
                      : null,
                  trailing: const Icon(Icons.directions_outlined),
                  onTap: () => lanceur.itineraire(
                    geo: c.adresseGeo,
                    adresse: c.adresseTexte ?? '',
                  ),
                ),
            ],
            const SizedBox(height: 24),
            if (_occupe)
              Center(
                child: CircularProgressIndicator(
                  semanticsLabel: l10n.chargement,
                ),
              )
            else if (widget.estPro && !c.statut.estTerminee) ...[
              if (suivant != null)
                FilledButton(
                  onPressed: () => _changer(suivant),
                  child: Text(l10n.actionVers(suivant)),
                ),
              if (c.statut == StatutCommande.nouvelle) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _refuser,
                  child: Text(l10n.refuserCommande),
                ),
              ],
            ] else if (!widget.estPro &&
                c.statut == StatutCommande.nouvelle) ...[
              if (c.methodePaiement == MethodePaiement.carte &&
                  (c.statutPaiement == StatutPaiement.enAttente ||
                      c.statutPaiement == StatutPaiement.echoue)) ...[
                FilledButton(
                  onPressed: _payer,
                  child: Text(l10n.payerMaintenant),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: _annuler,
                child: Text(l10n.annulerCommande),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Ligne extends StatelessWidget {
  const _Ligne(this.libelle, this.montant, {this.gras = false});

  final String libelle;
  final String montant;
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
          Expanded(child: Text(libelle, style: style)),
          Text(montant, style: style),
        ],
      ),
    );
  }
}

/// Étapes de la commande, les passées cochées avec leur heure.
class _Suivi extends StatelessWidget {
  const _Suivi({required this.commande});

  final Commande commande;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final langue = Localizations.localeOf(context).languageCode;
    final etapes =
        commande.statut == StatutCommande.refusee ||
            commande.statut == StatutCommande.annulee
        ? [StatutCommande.nouvelle, commande.statut]
        : [
            StatutCommande.nouvelle,
            StatutCommande.acceptee,
            StatutCommande.enPreparation,
            StatutCommande.prete,
            if (commande.mode == ModeCommande.livraison) ...[
              StatutCommande.enLivraison,
              StatutCommande.livree,
            ] else
              StatutCommande.retiree,
          ];
    final dates = {for (final e in commande.historique) e.statut: e.date};

    return Column(
      children: [
        for (final e in etapes)
          Row(
            children: [
              Icon(
                dates.containsKey(e)
                    ? (e == StatutCommande.refusee ||
                              e == StatutCommande.annulee
                          ? Icons.cancel
                          : Icons.check_circle)
                    : Icons.radio_button_unchecked,
                color: dates.containsKey(e)
                    ? (e == StatutCommande.refusee ||
                              e == StatutCommande.annulee
                          ? theme.colorScheme.error
                          : theme.colorScheme.secondary)
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    l10n.statutCommandeLibelle(e),
                    style: e == commande.statut
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.bodyMedium,
                  ),
                ),
              ),
              if (dates[e] != null)
                Text(
                  DateFormat.Hm(langue).format(dates[e]!),
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
      ],
    );
  }
}
