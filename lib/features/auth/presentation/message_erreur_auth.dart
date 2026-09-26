import '../../../l10n/app_localizations.dart';
import '../domain/erreur_auth.dart';

/// Texte affiché pour une erreur de connexion (null : rien à afficher).
String? messageErreurAuth(AppLocalizations l10n, Object erreur) {
  final type = erreur is ExceptionAuth ? erreur.erreur : ErreurAuth.inconnue;
  return switch (type) {
    ErreurAuth.annule => null,
    ErreurAuth.emailInvalide => l10n.erreurEmailInvalide,
    ErreurAuth.motDePasseFaible => l10n.erreurMotDePasseFaible,
    ErreurAuth.emailDejaUtilise => l10n.erreurEmailDejaUtilise,
    ErreurAuth.identifiantsIncorrects => l10n.erreurIdentifiantsIncorrects,
    ErreurAuth.tropDeTentatives => l10n.erreurTropDeTentatives,
    ErreurAuth.reseau => l10n.erreurReseau,
    ErreurAuth.inconnue => l10n.erreurInconnue,
  };
}
