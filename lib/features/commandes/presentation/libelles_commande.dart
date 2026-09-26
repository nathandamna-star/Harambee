import '../../../l10n/app_localizations.dart';
import '../../../shared/models/commande.dart';

extension LibellesCommande on AppLocalizations {
  String statutCommandeLibelle(StatutCommande s) => switch (s) {
    StatutCommande.nouvelle => cmdNouvelle,
    StatutCommande.acceptee => cmdAcceptee,
    StatutCommande.enPreparation => cmdEnPreparation,
    StatutCommande.prete => cmdPrete,
    StatutCommande.enLivraison => cmdEnLivraison,
    StatutCommande.livree => cmdLivree,
    StatutCommande.retiree => cmdRetiree,
    StatutCommande.refusee => cmdRefusee,
    StatutCommande.annulee => cmdAnnulee,
  };

  /// Libellé du bouton qui fait passer la commande à [s].
  String actionVers(StatutCommande s) => switch (s) {
    StatutCommande.acceptee => actionAccepter,
    StatutCommande.enPreparation => actionPreparer,
    StatutCommande.prete => actionPrete,
    StatutCommande.enLivraison => actionEnLivraison,
    StatutCommande.livree => actionLivree,
    StatutCommande.retiree => actionRetiree,
    _ => statutCommandeLibelle(s),
  };
}
