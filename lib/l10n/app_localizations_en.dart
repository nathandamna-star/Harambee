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

  @override
  String get bienvenueTitre => 'Welcome to Harambee';

  @override
  String get bienvenueSousTitre =>
      'African and Christian businesses near you and wherever you go.';

  @override
  String get choixClient => 'I\'m looking for a business';

  @override
  String get choixClientDetail => 'Find, contact, order';

  @override
  String get choixPro => 'I own a business';

  @override
  String get choixProDetail => 'Showcase my business and products';

  @override
  String get continuerGoogle => 'Continue with Google';

  @override
  String get continuerApple => 'Continue with Apple';

  @override
  String get continuerEmail => 'Continue with email';

  @override
  String get explorerSansCompte => 'Explore without an account';

  @override
  String get seConnecter => 'Sign in';

  @override
  String get creerCompte => 'Create an account';

  @override
  String get champNom => 'Name';

  @override
  String get champEmail => 'Email address';

  @override
  String get champMotDePasse => 'Password';

  @override
  String get afficherMotDePasse => 'Show password';

  @override
  String get masquerMotDePasse => 'Hide password';

  @override
  String get motDePasseOublie => 'Forgot password?';

  @override
  String emailReinitialisationEnvoye(String email) {
    return 'An email to choose a new password has been sent to $email.';
  }

  @override
  String get validationNomRequis => 'Enter your name.';

  @override
  String get validationEmail => 'Enter a valid email address.';

  @override
  String get validationMotDePasse => 'At least 8 characters.';

  @override
  String get erreurEmailInvalide => 'This email address is not valid.';

  @override
  String get erreurMotDePasseFaible =>
      'This password is too weak. Use at least 8 characters.';

  @override
  String get erreurEmailDejaUtilise =>
      'An account already exists with this email. Please sign in instead.';

  @override
  String get erreurIdentifiantsIncorrects => 'Incorrect email or password.';

  @override
  String get erreurTropDeTentatives =>
      'Too many attempts. Try again in a few minutes.';

  @override
  String get erreurReseau =>
      'No internet connection. Check your network and try again.';

  @override
  String get erreurInconnue => 'Something went wrong. Please try again.';

  @override
  String get connexionRequiseTitre => 'Sign in';

  @override
  String get connexionRequiseFavoris =>
      'Create an account or sign in to save your favorite businesses.';

  @override
  String get connexionRequiseMessages => 'Sign in to chat with businesses.';

  @override
  String get seDeconnecter => 'Sign out';

  @override
  String get roleClient => 'Customer';

  @override
  String get rolePro => 'Business owner';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String monEspaceBonjour(String nom) {
    return 'Hello $nom';
  }

  @override
  String get monEspaceProBientot =>
      'You\'ll soon be able to create your business page here.';

  @override
  String get chargement => 'Loading';
}
