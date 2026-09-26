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

  /// No description provided for @bienvenueTitre.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur Harambee'**
  String get bienvenueTitre;

  /// No description provided for @bienvenueSousTitre.
  ///
  /// In fr, this message translates to:
  /// **'Les commerces africains et chrétiens près de chez vous et partout où vous allez.'**
  String get bienvenueSousTitre;

  /// No description provided for @choixClient.
  ///
  /// In fr, this message translates to:
  /// **'Je cherche un commerce'**
  String get choixClient;

  /// No description provided for @choixClientDetail.
  ///
  /// In fr, this message translates to:
  /// **'Trouver, contacter, commander'**
  String get choixClientDetail;

  /// No description provided for @choixPro.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai un commerce'**
  String get choixPro;

  /// No description provided for @choixProDetail.
  ///
  /// In fr, this message translates to:
  /// **'Présenter mon commerce et mes produits'**
  String get choixProDetail;

  /// No description provided for @continuerGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get continuerGoogle;

  /// No description provided for @continuerApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get continuerApple;

  /// No description provided for @continuerEmail.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec l\'e-mail'**
  String get continuerEmail;

  /// No description provided for @explorerSansCompte.
  ///
  /// In fr, this message translates to:
  /// **'Explorer sans compte'**
  String get explorerSansCompte;

  /// No description provided for @seConnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get seConnecter;

  /// No description provided for @creerCompte.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get creerCompte;

  /// No description provided for @champNom.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get champNom;

  /// No description provided for @champEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get champEmail;

  /// No description provided for @champMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get champMotDePasse;

  /// No description provided for @afficherMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get afficherMotDePasse;

  /// No description provided for @masquerMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get masquerMotDePasse;

  /// No description provided for @motDePasseOublie.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get motDePasseOublie;

  /// No description provided for @emailReinitialisationEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Un e-mail pour choisir un nouveau mot de passe a été envoyé à {email}.'**
  String emailReinitialisationEnvoye(String email);

  /// No description provided for @validationNomRequis.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez votre nom.'**
  String get validationNomRequis;

  /// No description provided for @validationEmail.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez une adresse e-mail valide.'**
  String get validationEmail;

  /// No description provided for @validationMotDePasse.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caractères.'**
  String get validationMotDePasse;

  /// No description provided for @erreurEmailInvalide.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse e-mail n\'est pas valide.'**
  String get erreurEmailInvalide;

  /// No description provided for @erreurMotDePasseFaible.
  ///
  /// In fr, this message translates to:
  /// **'Ce mot de passe est trop faible. Utilisez au moins 8 caractères.'**
  String get erreurMotDePasseFaible;

  /// No description provided for @erreurEmailDejaUtilise.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse. Connectez-vous plutôt.'**
  String get erreurEmailDejaUtilise;

  /// No description provided for @erreurIdentifiantsIncorrects.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail ou mot de passe incorrect.'**
  String get erreurIdentifiantsIncorrects;

  /// No description provided for @erreurTropDeTentatives.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Réessayez dans quelques minutes.'**
  String get erreurTropDeTentatives;

  /// No description provided for @erreurReseau.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Vérifiez votre réseau et réessayez.'**
  String get erreurReseau;

  /// No description provided for @erreurInconnue.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue. Réessayez.'**
  String get erreurInconnue;

  /// No description provided for @connexionRequiseTitre.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous'**
  String get connexionRequiseTitre;

  /// No description provided for @connexionRequiseFavoris.
  ///
  /// In fr, this message translates to:
  /// **'Créez un compte ou connectez-vous pour enregistrer vos commerces préférés.'**
  String get connexionRequiseFavoris;

  /// No description provided for @connexionRequiseMessages.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour échanger avec les commerces.'**
  String get connexionRequiseMessages;

  /// No description provided for @seDeconnecter.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get seDeconnecter;

  /// No description provided for @roleClient.
  ///
  /// In fr, this message translates to:
  /// **'Client'**
  String get roleClient;

  /// No description provided for @rolePro.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel'**
  String get rolePro;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @monEspaceBonjour.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour {nom}'**
  String monEspaceBonjour(String nom);

  /// No description provided for @chargement.
  ///
  /// In fr, this message translates to:
  /// **'Chargement'**
  String get chargement;

  /// No description provided for @actions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @afficher.
  ///
  /// In fr, this message translates to:
  /// **'Afficher'**
  String get afficher;

  /// No description provided for @ajouterPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get ajouterPhoto;

  /// No description provided for @ajouterProduit.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un produit'**
  String get ajouterProduit;

  /// No description provided for @annuler.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get annuler;

  /// No description provided for @aucunCommerceTitre.
  ///
  /// In fr, this message translates to:
  /// **'Présentez votre commerce'**
  String get aucunCommerceTitre;

  /// No description provided for @aucunCommerceTexte.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre fiche en 3 étapes. Notre équipe la vérifie avant sa publication.'**
  String get aucunCommerceTexte;

  /// No description provided for @badgeMasque.
  ///
  /// In fr, this message translates to:
  /// **'Masqué'**
  String get badgeMasque;

  /// No description provided for @badgeRupture.
  ///
  /// In fr, this message translates to:
  /// **'En rupture'**
  String get badgeRupture;

  /// No description provided for @catalogue.
  ///
  /// In fr, this message translates to:
  /// **'Catalogue'**
  String get catalogue;

  /// No description provided for @catalogueVideTitre.
  ///
  /// In fr, this message translates to:
  /// **'Votre catalogue est vide'**
  String get catalogueVideTitre;

  /// No description provided for @catalogueVideTexte.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos produits ou services avec leur prix pour les présenter à vos clients.'**
  String get catalogueVideTexte;

  /// No description provided for @categorieMagasin.
  ///
  /// In fr, this message translates to:
  /// **'Magasin'**
  String get categorieMagasin;

  /// No description provided for @categorieRestaurant.
  ///
  /// In fr, this message translates to:
  /// **'Restaurant'**
  String get categorieRestaurant;

  /// No description provided for @categorieLogement.
  ///
  /// In fr, this message translates to:
  /// **'Logement'**
  String get categorieLogement;

  /// No description provided for @categorieService.
  ///
  /// In fr, this message translates to:
  /// **'Service'**
  String get categorieService;

  /// No description provided for @champAdresse.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get champAdresse;

  /// No description provided for @champCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get champCategorie;

  /// No description provided for @champDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get champDescription;

  /// No description provided for @champDevise.
  ///
  /// In fr, this message translates to:
  /// **'Devise'**
  String get champDevise;

  /// No description provided for @champHoraires.
  ///
  /// In fr, this message translates to:
  /// **'Horaires d\'ouverture'**
  String get champHoraires;

  /// No description provided for @champNomCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Nom du commerce'**
  String get champNomCommerce;

  /// No description provided for @champNomProduit.
  ///
  /// In fr, this message translates to:
  /// **'Nom du produit'**
  String get champNomProduit;

  /// No description provided for @champObligatoire.
  ///
  /// In fr, this message translates to:
  /// **'Ce champ est obligatoire.'**
  String get champObligatoire;

  /// No description provided for @champPays.
  ///
  /// In fr, this message translates to:
  /// **'Pays'**
  String get champPays;

  /// No description provided for @champPrix.
  ///
  /// In fr, this message translates to:
  /// **'Prix'**
  String get champPrix;

  /// No description provided for @champTelephone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get champTelephone;

  /// No description provided for @champVille.
  ///
  /// In fr, this message translates to:
  /// **'Ville'**
  String get champVille;

  /// No description provided for @charteTitre.
  ///
  /// In fr, this message translates to:
  /// **'Charte chrétienne'**
  String get charteTitre;

  /// No description provided for @charteTexteProvisoire.
  ///
  /// In fr, this message translates to:
  /// **'Le texte de la charte chrétienne sera bientôt disponible. En l\'acceptant, vous vous engagez à en respecter les principes dans la gestion de votre commerce.'**
  String get charteTexteProvisoire;

  /// No description provided for @charteJAccepte.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai lu et j\'accepte la charte'**
  String get charteJAccepte;

  /// No description provided for @charteAcceptee.
  ///
  /// In fr, this message translates to:
  /// **'Charte acceptée'**
  String get charteAcceptee;

  /// No description provided for @creerFiche.
  ///
  /// In fr, this message translates to:
  /// **'Créer la fiche de mon commerce'**
  String get creerFiche;

  /// No description provided for @enregistrer.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get enregistrer;

  /// No description provided for @envoyerPourVerification.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer pour vérification'**
  String get envoyerPourVerification;

  /// No description provided for @erreurEnregistrement.
  ///
  /// In fr, this message translates to:
  /// **'L\'enregistrement a échoué. Vérifiez votre connexion et réessayez.'**
  String get erreurEnregistrement;

  /// No description provided for @etapeInfos.
  ///
  /// In fr, this message translates to:
  /// **'Votre commerce'**
  String get etapeInfos;

  /// No description provided for @etapeLabels.
  ///
  /// In fr, this message translates to:
  /// **'Labels'**
  String get etapeLabels;

  /// No description provided for @etapePhotos.
  ///
  /// In fr, this message translates to:
  /// **'Photos'**
  String get etapePhotos;

  /// No description provided for @etapeXsurY.
  ///
  /// In fr, this message translates to:
  /// **'Étape {etape} sur {total}'**
  String etapeXsurY(int etape, int total);

  /// No description provided for @ferme.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get ferme;

  /// No description provided for @ficheEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Fiche enregistrée.'**
  String get ficheEnregistree;

  /// No description provided for @ficheEnvoyee.
  ///
  /// In fr, this message translates to:
  /// **'Merci ! Votre fiche a été envoyée. Elle sera visible dès que notre équipe l\'aura vérifiée.'**
  String get ficheEnvoyee;

  /// No description provided for @jourLundi.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get jourLundi;

  /// No description provided for @jourMardi.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get jourMardi;

  /// No description provided for @jourMercredi.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get jourMercredi;

  /// No description provided for @jourJeudi.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get jourJeudi;

  /// No description provided for @jourVendredi.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get jourVendredi;

  /// No description provided for @jourSamedi.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get jourSamedi;

  /// No description provided for @jourDimanche.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get jourDimanche;

  /// No description provided for @labelsExplication.
  ///
  /// In fr, this message translates to:
  /// **'Demandez les labels qui correspondent à votre commerce. Notre équipe les vérifie avant de les afficher.'**
  String get labelsExplication;

  /// No description provided for @labelsModifiablesAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Les labels sont attribués par l\'équipe Harambee. Contactez-nous pour les modifier.'**
  String get labelsModifiablesAdmin;

  /// No description provided for @labelAfricainDetail.
  ///
  /// In fr, this message translates to:
  /// **'Commerce tenu par des personnes d\'origine africaine ou proposant des produits africains.'**
  String get labelAfricainDetail;

  /// No description provided for @labelChretienDetail.
  ///
  /// In fr, this message translates to:
  /// **'Commerce tenu par des chrétiens engagés à respecter la charte chrétienne.'**
  String get labelChretienDetail;

  /// No description provided for @lireCharte.
  ///
  /// In fr, this message translates to:
  /// **'Lire et accepter la charte'**
  String get lireCharte;

  /// No description provided for @localisationDesactivee.
  ///
  /// In fr, this message translates to:
  /// **'La localisation est désactivée. Activez-la dans les réglages du téléphone.'**
  String get localisationDesactivee;

  /// No description provided for @localisationRefusee.
  ///
  /// In fr, this message translates to:
  /// **'Harambee n\'a pas accès à votre position. Autorisez-la dans les réglages du téléphone.'**
  String get localisationRefusee;

  /// No description provided for @localisationIndisponible.
  ///
  /// In fr, this message translates to:
  /// **'Position introuvable. Réessayez à l\'extérieur ou plus tard.'**
  String get localisationIndisponible;

  /// No description provided for @marquerDisponible.
  ///
  /// In fr, this message translates to:
  /// **'Marquer disponible'**
  String get marquerDisponible;

  /// No description provided for @marquerRupture.
  ///
  /// In fr, this message translates to:
  /// **'Marquer en rupture'**
  String get marquerRupture;

  /// No description provided for @masquer.
  ///
  /// In fr, this message translates to:
  /// **'Masquer'**
  String get masquer;

  /// No description provided for @modifier.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get modifier;

  /// No description provided for @modifierFiche.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la fiche'**
  String get modifierFiche;

  /// No description provided for @modifierProduit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le produit'**
  String get modifierProduit;

  /// No description provided for @monCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Mon commerce'**
  String get monCommerce;

  /// No description provided for @photoCamera.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get photoCamera;

  /// No description provided for @photoGalerie.
  ///
  /// In fr, this message translates to:
  /// **'Choisir dans la galerie'**
  String get photoGalerie;

  /// No description provided for @photosAide.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez jusqu\'à {max} photos : la devanture, l\'intérieur, vos produits. Une première photo claire attire plus de clients.'**
  String photosAide(int max);

  /// No description provided for @positionAbsente.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer la position du commerce'**
  String get positionAbsente;

  /// No description provided for @positionEnregistree.
  ///
  /// In fr, this message translates to:
  /// **'Position enregistrée'**
  String get positionEnregistree;

  /// No description provided for @positionAide.
  ///
  /// In fr, this message translates to:
  /// **'Touchez ici depuis votre commerce pour apparaître dans les recherches « près de moi ».'**
  String get positionAide;

  /// No description provided for @precedent.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get precedent;

  /// No description provided for @produitIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Ce produit n\'existe plus.'**
  String get produitIntrouvable;

  /// No description provided for @produitVisible.
  ///
  /// In fr, this message translates to:
  /// **'Visible par les clients'**
  String get produitVisible;

  /// No description provided for @produitVisibleAide.
  ///
  /// In fr, this message translates to:
  /// **'Désactivez pour masquer le produit sans le supprimer.'**
  String get produitVisibleAide;

  /// No description provided for @retirerPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la photo'**
  String get retirerPhoto;

  /// No description provided for @statutEnVerification.
  ///
  /// In fr, this message translates to:
  /// **'En vérification'**
  String get statutEnVerification;

  /// No description provided for @statutEnVerificationAide.
  ///
  /// In fr, this message translates to:
  /// **'Notre équipe vérifie votre fiche. Vous pouvez déjà préparer votre catalogue.'**
  String get statutEnVerificationAide;

  /// No description provided for @statutPublie.
  ///
  /// In fr, this message translates to:
  /// **'Publié'**
  String get statutPublie;

  /// No description provided for @statutPublieAide.
  ///
  /// In fr, this message translates to:
  /// **'Votre fiche est visible par tous les clients.'**
  String get statutPublieAide;

  /// No description provided for @statutSuspendu.
  ///
  /// In fr, this message translates to:
  /// **'Suspendu'**
  String get statutSuspendu;

  /// No description provided for @statutSuspenduAide.
  ///
  /// In fr, this message translates to:
  /// **'Votre fiche n\'est plus visible. Contactez-nous pour en savoir plus.'**
  String get statutSuspenduAide;

  /// No description provided for @statutSuspenduMotif.
  ///
  /// In fr, this message translates to:
  /// **'Votre fiche n\'est plus visible. Motif : {motif}'**
  String statutSuspenduMotif(String motif);

  /// No description provided for @suivant.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get suivant;

  /// No description provided for @supprimer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get supprimer;

  /// No description provided for @supprimerProduitTitre.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce produit ?'**
  String get supprimerProduitTitre;

  /// No description provided for @supprimerProduitTexte.
  ///
  /// In fr, this message translates to:
  /// **'« {nom} » sera définitivement supprimé. Pour le cacher temporairement, utilisez plutôt « Masquer ».'**
  String supprimerProduitTexte(String nom);

  /// No description provided for @validationCategorie.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une catégorie.'**
  String get validationCategorie;

  /// No description provided for @validationCharte.
  ///
  /// In fr, this message translates to:
  /// **'Pour demander le label « Chrétien », acceptez d\'abord la charte.'**
  String get validationCharte;

  /// No description provided for @validationPrix.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un prix valide (ex. 8,50).'**
  String get validationPrix;

  /// No description provided for @valider.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get valider;

  /// No description provided for @vousAvezUnCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez un commerce ?'**
  String get vousAvezUnCommerce;

  /// No description provided for @vousAvezUnCommerceAide.
  ///
  /// In fr, this message translates to:
  /// **'Passez en compte professionnel pour le présenter sur Harambee.'**
  String get vousAvezUnCommerceAide;

  /// No description provided for @activerAdminTitre.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'accès administrateur ?'**
  String get activerAdminTitre;

  /// No description provided for @activerAdminTexte.
  ///
  /// In fr, this message translates to:
  /// **'Réservé au responsable de Harambee. Seul le compte désigné lors de la mise en service peut devenir le premier administrateur.'**
  String get activerAdminTexte;

  /// No description provided for @adminActive.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes maintenant administrateur. L\'onglet Admin est disponible.'**
  String get adminActive;

  /// No description provided for @adminAucunCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Aucun commerce ici pour l\'instant.'**
  String get adminAucunCommerce;

  /// No description provided for @adminAucunSignalement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun signalement à traiter.'**
  String get adminAucunSignalement;

  /// No description provided for @adminEnAttente.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get adminEnAttente;

  /// No description provided for @adminPublies.
  ///
  /// In fr, this message translates to:
  /// **'Publiés'**
  String get adminPublies;

  /// No description provided for @adminSuspendus.
  ///
  /// In fr, this message translates to:
  /// **'Suspendus'**
  String get adminSuspendus;

  /// No description provided for @adminSignalements.
  ///
  /// In fr, this message translates to:
  /// **'Signalements'**
  String get adminSignalements;

  /// No description provided for @adminRienAVerifier.
  ///
  /// In fr, this message translates to:
  /// **'Tout est vérifié !'**
  String get adminRienAVerifier;

  /// No description provided for @adminNomme.
  ///
  /// In fr, this message translates to:
  /// **'{email} est maintenant administrateur. Il doit se déconnecter puis se reconnecter.'**
  String adminNomme(String email);

  /// No description provided for @adminRetire.
  ///
  /// In fr, this message translates to:
  /// **'{email} n\'est plus administrateur.'**
  String adminRetire(String email);

  /// No description provided for @administrateurs.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs'**
  String get administrateurs;

  /// No description provided for @administrateursAide.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez l\'adresse e-mail d\'un compte Harambee existant pour lui donner ou lui retirer l\'accès administrateur.'**
  String get administrateursAide;

  /// No description provided for @aucunePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo.'**
  String get aucunePhoto;

  /// No description provided for @charteNonSignee.
  ///
  /// In fr, this message translates to:
  /// **'Charte chrétienne non signée'**
  String get charteNonSignee;

  /// No description provided for @charteSigneeLe.
  ///
  /// In fr, this message translates to:
  /// **'Charte signée le {date}'**
  String charteSigneeLe(String date);

  /// No description provided for @cibleCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Commerce signalé'**
  String get cibleCommerce;

  /// No description provided for @cibleAvis.
  ///
  /// In fr, this message translates to:
  /// **'Avis signalé'**
  String get cibleAvis;

  /// No description provided for @cibleMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message signalé'**
  String get cibleMessage;

  /// No description provided for @commerceIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Ce commerce n\'existe plus.'**
  String get commerceIntrouvable;

  /// No description provided for @enregistrerLabels.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les labels'**
  String get enregistrerLabels;

  /// No description provided for @erreurAdminNonAutorise.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte n\'est pas autorisé à faire cette action.'**
  String get erreurAdminNonAutorise;

  /// No description provided for @erreurAdminCompteIntrouvable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun compte Harambee avec cette adresse e-mail.'**
  String get erreurAdminCompteIntrouvable;

  /// No description provided for @erreurAdminDejaDesigne.
  ///
  /// In fr, this message translates to:
  /// **'Le premier administrateur a déjà été désigné.'**
  String get erreurAdminDejaDesigne;

  /// No description provided for @erreurAdminSoiMeme.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas retirer votre propre accès.'**
  String get erreurAdminSoiMeme;

  /// No description provided for @fichePubliee.
  ///
  /// In fr, this message translates to:
  /// **'Fiche publiée.'**
  String get fichePubliee;

  /// No description provided for @ficheRefusee.
  ///
  /// In fr, this message translates to:
  /// **'Fiche refusée. Le commerçant verra le motif.'**
  String get ficheRefusee;

  /// No description provided for @ficheSuspendue.
  ///
  /// In fr, this message translates to:
  /// **'Fiche suspendue.'**
  String get ficheSuspendue;

  /// No description provided for @labelsAConfirmer.
  ///
  /// In fr, this message translates to:
  /// **'Labels'**
  String get labelsAConfirmer;

  /// No description provided for @labelsAConfirmerAide.
  ///
  /// In fr, this message translates to:
  /// **'Demandés par le commerçant. Confirmez ou retirez-les avant de publier.'**
  String get labelsAConfirmerAide;

  /// No description provided for @labelsEnregistres.
  ///
  /// In fr, this message translates to:
  /// **'Labels enregistrés.'**
  String get labelsEnregistres;

  /// No description provided for @marquerTraite.
  ///
  /// In fr, this message translates to:
  /// **'Marquer comme traité'**
  String get marquerTraite;

  /// No description provided for @motif.
  ///
  /// In fr, this message translates to:
  /// **'Motif'**
  String get motif;

  /// No description provided for @motifAide.
  ///
  /// In fr, this message translates to:
  /// **'Il sera affiché au commerçant dans son espace.'**
  String get motifAide;

  /// No description provided for @motifActuel.
  ///
  /// In fr, this message translates to:
  /// **'Motif : {motif}'**
  String motifActuel(String motif);

  /// No description provided for @nommerAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Nommer administrateur'**
  String get nommerAdmin;

  /// No description provided for @retirerAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Retirer l\'accès administrateur'**
  String get retirerAdmin;

  /// No description provided for @positionGps.
  ///
  /// In fr, this message translates to:
  /// **'Position GPS'**
  String get positionGps;

  /// No description provided for @positionNonRenseignee.
  ///
  /// In fr, this message translates to:
  /// **'Non renseignée : le commerce n\'apparaîtra pas dans la recherche par distance.'**
  String get positionNonRenseignee;

  /// No description provided for @publierFiche.
  ///
  /// In fr, this message translates to:
  /// **'Publier la fiche'**
  String get publierFiche;

  /// No description provided for @refuserFiche.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get refuserFiche;

  /// No description provided for @republierFiche.
  ///
  /// In fr, this message translates to:
  /// **'Republier la fiche'**
  String get republierFiche;

  /// No description provided for @suspendreFiche.
  ///
  /// In fr, this message translates to:
  /// **'Suspendre la fiche'**
  String get suspendreFiche;

  /// No description provided for @voirCommerce.
  ///
  /// In fr, this message translates to:
  /// **'Voir le commerce'**
  String get voirCommerce;

  /// No description provided for @ajouterFavori.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux favoris'**
  String get ajouterFavori;

  /// No description provided for @retirerFavori.
  ///
  /// In fr, this message translates to:
  /// **'Retirer des favoris'**
  String get retirerFavori;

  /// No description provided for @anonyme.
  ///
  /// In fr, this message translates to:
  /// **'Anonyme'**
  String get anonyme;

  /// No description provided for @appeler.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get appeler;

  /// No description provided for @itineraire.
  ///
  /// In fr, this message translates to:
  /// **'Itinéraire'**
  String get itineraire;

  /// No description provided for @envoyerMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get envoyerMessage;

  /// No description provided for @messagerieBientot.
  ///
  /// In fr, this message translates to:
  /// **'La messagerie arrive bientôt.'**
  String get messagerieBientot;

  /// No description provided for @aucunAvis.
  ///
  /// In fr, this message translates to:
  /// **'Aucun avis pour l\'instant. Soyez le premier !'**
  String get aucunAvis;

  /// No description provided for @aucunProduitPublic.
  ///
  /// In fr, this message translates to:
  /// **'Ce commerce n\'a pas encore publié de produits.'**
  String get aucunProduitPublic;

  /// No description provided for @aucunResultatTitre.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get aucunResultatTitre;

  /// No description provided for @aucunResultatTexte.
  ///
  /// In fr, this message translates to:
  /// **'Essayez un autre mot ou retirez des filtres.'**
  String get aucunResultatTexte;

  /// No description provided for @choisirNote.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une note de 1 à 5 étoiles.'**
  String get choisirNote;

  /// No description provided for @continent.
  ///
  /// In fr, this message translates to:
  /// **'Continent'**
  String get continent;

  /// No description provided for @continentEurope.
  ///
  /// In fr, this message translates to:
  /// **'Europe'**
  String get continentEurope;

  /// No description provided for @continentAfrique.
  ///
  /// In fr, this message translates to:
  /// **'Afrique'**
  String get continentAfrique;

  /// No description provided for @continentAmerique.
  ///
  /// In fr, this message translates to:
  /// **'Amérique'**
  String get continentAmerique;

  /// No description provided for @donnerAvisTitre.
  ///
  /// In fr, this message translates to:
  /// **'Vous connaissez ce commerce ?'**
  String get donnerAvisTitre;

  /// No description provided for @donnerAvis.
  ///
  /// In fr, this message translates to:
  /// **'Donner mon avis'**
  String get donnerAvis;

  /// No description provided for @monAvis.
  ///
  /// In fr, this message translates to:
  /// **'Mon avis'**
  String get monAvis;

  /// No description provided for @modifierMonAvis.
  ///
  /// In fr, this message translates to:
  /// **'Modifier mon avis'**
  String get modifierMonAvis;

  /// No description provided for @votreAvis.
  ///
  /// In fr, this message translates to:
  /// **'Votre avis (facultatif)'**
  String get votreAvis;

  /// No description provided for @publierAvis.
  ///
  /// In fr, this message translates to:
  /// **'Publier'**
  String get publierAvis;

  /// No description provided for @effacerRecherche.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la recherche'**
  String get effacerRecherche;

  /// No description provided for @fermeMaintenant.
  ///
  /// In fr, this message translates to:
  /// **'Fermé'**
  String get fermeMaintenant;

  /// No description provided for @ouvert.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert'**
  String get ouvert;

  /// No description provided for @ouvertMaintenant.
  ///
  /// In fr, this message translates to:
  /// **'Ouvert maintenant'**
  String get ouvertMaintenant;

  /// No description provided for @filtres.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get filtres;

  /// No description provided for @horairesNonRenseignes.
  ///
  /// In fr, this message translates to:
  /// **'Horaires non renseignés.'**
  String get horairesNonRenseignes;

  /// No description provided for @ongletProduits.
  ///
  /// In fr, this message translates to:
  /// **'Produits'**
  String get ongletProduits;

  /// No description provided for @ongletAvis.
  ///
  /// In fr, this message translates to:
  /// **'Avis'**
  String get ongletAvis;

  /// No description provided for @ongletInfos.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get ongletInfos;

  /// No description provided for @rechercherIndice.
  ///
  /// In fr, this message translates to:
  /// **'Un commerce, une ville…'**
  String get rechercherIndice;

  /// No description provided for @reinitialiser.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reinitialiser;

  /// No description provided for @voirResultats.
  ///
  /// In fr, this message translates to:
  /// **'Voir les résultats'**
  String get voirResultats;

  /// No description provided for @voirPlus.
  ///
  /// In fr, this message translates to:
  /// **'Voir plus'**
  String get voirPlus;

  /// No description provided for @tous.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get tous;

  /// No description provided for @signaler.
  ///
  /// In fr, this message translates to:
  /// **'Signaler'**
  String get signaler;

  /// No description provided for @signalerAide.
  ///
  /// In fr, this message translates to:
  /// **'Expliquez ce qui pose problème. Notre équipe examinera votre signalement.'**
  String get signalerAide;

  /// No description provided for @signalementEnvoye.
  ///
  /// In fr, this message translates to:
  /// **'Merci. Notre équipe va examiner ce signalement.'**
  String get signalementEnvoye;

  /// No description provided for @nEtoiles.
  ///
  /// In fr, this message translates to:
  /// **'{n, plural, =1{1 étoile} other{{n} étoiles}}'**
  String nEtoiles(int n);

  /// No description provided for @noteSur5.
  ///
  /// In fr, this message translates to:
  /// **'Note {note} sur 5, {nb, plural, =1{1 avis} other{{nb} avis}}'**
  String noteSur5(String note, int nb);
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
