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

  @override
  String get bienvenueTitre => 'Bienvenue sur Harambee';

  @override
  String get bienvenueSousTitre =>
      'Les commerces africains et chrétiens près de chez vous et partout où vous allez.';

  @override
  String get choixClient => 'Je cherche un commerce';

  @override
  String get choixClientDetail => 'Trouver, contacter, commander';

  @override
  String get choixPro => 'J\'ai un commerce';

  @override
  String get choixProDetail => 'Présenter mon commerce et mes produits';

  @override
  String get continuerGoogle => 'Continuer avec Google';

  @override
  String get continuerApple => 'Continuer avec Apple';

  @override
  String get continuerEmail => 'Continuer avec l\'e-mail';

  @override
  String get explorerSansCompte => 'Explorer sans compte';

  @override
  String get seConnecter => 'Se connecter';

  @override
  String get creerCompte => 'Créer un compte';

  @override
  String get champNom => 'Nom';

  @override
  String get champEmail => 'Adresse e-mail';

  @override
  String get champMotDePasse => 'Mot de passe';

  @override
  String get afficherMotDePasse => 'Afficher le mot de passe';

  @override
  String get masquerMotDePasse => 'Masquer le mot de passe';

  @override
  String get motDePasseOublie => 'Mot de passe oublié ?';

  @override
  String emailReinitialisationEnvoye(String email) {
    return 'Un e-mail pour choisir un nouveau mot de passe a été envoyé à $email.';
  }

  @override
  String get validationNomRequis => 'Indiquez votre nom.';

  @override
  String get validationEmail => 'Indiquez une adresse e-mail valide.';

  @override
  String get validationMotDePasse => 'Au moins 8 caractères.';

  @override
  String get erreurEmailInvalide => 'Cette adresse e-mail n\'est pas valide.';

  @override
  String get erreurMotDePasseFaible =>
      'Ce mot de passe est trop faible. Utilisez au moins 8 caractères.';

  @override
  String get erreurEmailDejaUtilise =>
      'Un compte existe déjà avec cette adresse. Connectez-vous plutôt.';

  @override
  String get erreurIdentifiantsIncorrects =>
      'Adresse e-mail ou mot de passe incorrect.';

  @override
  String get erreurTropDeTentatives =>
      'Trop de tentatives. Réessayez dans quelques minutes.';

  @override
  String get erreurReseau =>
      'Pas de connexion internet. Vérifiez votre réseau et réessayez.';

  @override
  String get erreurInconnue => 'Une erreur est survenue. Réessayez.';

  @override
  String get connexionRequiseTitre => 'Connectez-vous';

  @override
  String get connexionRequiseFavoris =>
      'Créez un compte ou connectez-vous pour enregistrer vos commerces préférés.';

  @override
  String get connexionRequiseMessages =>
      'Connectez-vous pour échanger avec les commerces.';

  @override
  String get seDeconnecter => 'Se déconnecter';

  @override
  String get roleClient => 'Client';

  @override
  String get rolePro => 'Professionnel';

  @override
  String get roleAdmin => 'Administrateur';

  @override
  String monEspaceBonjour(String nom) {
    return 'Bonjour $nom';
  }

  @override
  String get monEspaceProBientot =>
      'Vous pourrez bientôt créer la fiche de votre commerce ici.';

  @override
  String get chargement => 'Chargement';
}
