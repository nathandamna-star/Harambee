import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// Nom de l'application
  ///
  /// In fr, this message translates to:
  /// **'Harambee'**
  String get appTitle;

  /// No description provided for @navExplorer.
  ///
  /// In fr, this message translates to:
  /// **'Explorer'**
  String get navExplorer;

  /// No description provided for @navFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Favoris'**
  String get navFavoris;

  /// No description provided for @navMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navMonEspace.
  ///
  /// In fr, this message translates to:
  /// **'Mon espace'**
  String get navMonEspace;

  /// No description provided for @navAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Admin'**
  String get navAdmin;

  /// No description provided for @explorerVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez un commerce près de chez vous'**
  String get explorerVideTitre;

  /// No description provided for @explorerVideTexte.
  ///
  /// In fr, this message translates to:
  /// **'Magasins, restaurants, logements et services africains et chrétiens, en Europe, en Afrique et en Amérique.'**
  String get explorerVideTexte;

  /// No description provided for @favorisVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Aucun favori pour l\'instant'**
  String get favorisVideTitre;

  /// No description provided for @favorisVideTexte.
  ///
  /// In fr, this message translates to:
  /// **'Touchez le cœur sur la fiche d\'un commerce pour le retrouver ici.'**
  String get favorisVideTexte;

  /// No description provided for @messagesVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation'**
  String get messagesVideTitre;

  /// No description provided for @messagesVideTexte.
  ///
  /// In fr, this message translates to:
  /// **'Vos échanges avec les commerces apparaîtront ici.'**
  String get messagesVideTexte;

  /// No description provided for @monEspaceVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Votre espace'**
  String get monEspaceVideTitre;

  /// No description provided for @monEspaceVideTexte.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour gérer votre profil ou votre commerce.'**
  String get monEspaceVideTexte;

  /// No description provided for @adminVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get adminVideTitre;

  /// No description provided for @adminVideTexte.
  ///
  /// In fr, this message translates to:
  /// **'Les commerces en attente de vérification et les signalements apparaîtront ici.'**
  String get adminVideTexte;

  /// No description provided for @labelAfricain.
  ///
  /// In fr, this message translates to:
  /// **'Africain'**
  String get labelAfricain;

  /// No description provided for @labelChretien.
  ///
  /// In fr, this message translates to:
  /// **'Chrétien'**
  String get labelChretien;

  /// No description provided for @badgeVerifie.
  ///
  /// In fr, this message translates to:
  /// **'Vérifié'**
  String get badgeVerifie;

  /// No description provided for @bientotDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt disponible'**
  String get bientotDisponible;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
