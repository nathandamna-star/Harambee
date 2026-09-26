// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Harambee';

  @override
  String get navExplorer => 'Explorer';

  @override
  String get navFavoris => 'Favoris';

  @override
  String get navMessages => 'Messages';

  @override
  String get navMonEspace => 'Mon espace';

  @override
  String get navAdmin => 'Admin';

  @override
  String get explorerVideTitre => 'Trouvez un commerce près de chez vous';

  @override
  String get explorerVideTexte =>
      'Magasins, restaurants, logements et services africains et chrétiens, en Europe, en Afrique et en Amérique.';

  @override
  String get favorisVideTitre => 'Aucun favori pour l\'instant';

  @override
  String get favorisVideTexte =>
      'Touchez le cœur sur la fiche d\'un commerce pour le retrouver ici.';

  @override
  String get messagesVideTitre => 'Aucune conversation';

  @override
  String get messagesVideTexte =>
      'Vos échanges avec les commerces apparaîtront ici.';

  @override
  String get monEspaceVideTitre => 'Votre espace';

  @override
  String get monEspaceVideTexte =>
      'Connectez-vous pour gérer votre profil ou votre commerce.';

  @override
  String get adminVideTitre => 'Administration';

  @override
  String get adminVideTexte =>
      'Les commerces en attente de vérification et les signalements apparaîtront ici.';

  @override
  String get labelAfricain => 'Africain';

  @override
  String get labelChretien => 'Chrétien';

  @override
  String get badgeVerifie => 'Vérifié';

  @override
  String get bientotDisponible => 'Bientôt disponible';
}
