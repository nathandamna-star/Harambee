// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Harambee';

  @override
  String get navExplorer => 'Explore';

  @override
  String get navFavoris => 'Favorites';

  @override
  String get navMessages => 'Messages';

  @override
  String get navMonEspace => 'My space';

  @override
  String get navAdmin => 'Admin';

  @override
  String get explorerVideTitre => 'Find a business near you';

  @override
  String get explorerVideTexte =>
      'African and Christian shops, restaurants, housing and services across Europe, Africa and the Americas.';

  @override
  String get favorisVideTitre => 'No favorites yet';

  @override
  String get favorisVideTexte =>
      'Tap the heart on a business page to find it here.';

  @override
  String get messagesVideTitre => 'No conversations';

  @override
  String get messagesVideTexte =>
      'Your conversations with businesses will appear here.';

  @override
  String get monEspaceVideTitre => 'Your space';

  @override
  String get monEspaceVideTexte =>
      'Sign in to manage your profile or your business.';

  @override
  String get adminVideTitre => 'Administration';

  @override
  String get adminVideTexte =>
      'Businesses awaiting verification and reports will appear here.';

  @override
  String get labelAfricain => 'African';

  @override
  String get labelChretien => 'Christian';

  @override
  String get badgeVerifie => 'Verified';

  @override
  String get bientotDisponible => 'Coming soon';
}
