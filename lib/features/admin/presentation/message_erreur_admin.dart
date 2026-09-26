import '../../../l10n/app_localizations.dart';
import '../data/fonctions_admin.dart';

String messageErreurAdmin(AppLocalizations l10n, Object erreur) {
  final type = erreur is ExceptionAdmin ? erreur.erreur : ErreurAdmin.inconnue;
  return switch (type) {
    ErreurAdmin.nonAutorise => l10n.erreurAdminNonAutorise,
    ErreurAdmin.compteIntrouvable => l10n.erreurAdminCompteIntrouvable,
    ErreurAdmin.dejaDesigne => l10n.erreurAdminDejaDesigne,
    ErreurAdmin.soiMeme => l10n.erreurAdminSoiMeme,
    ErreurAdmin.reseau => l10n.erreurReseau,
    ErreurAdmin.inconnue => l10n.erreurInconnue,
  };
}
