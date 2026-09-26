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
  String get chargement => 'Chargement';

  @override
  String get actions => 'Actions';

  @override
  String get afficher => 'Afficher';

  @override
  String get ajouterPhoto => 'Ajouter une photo';

  @override
  String get ajouterProduit => 'Ajouter un produit';

  @override
  String get annuler => 'Annuler';

  @override
  String get aucunCommerceTitre => 'Présentez votre commerce';

  @override
  String get aucunCommerceTexte =>
      'Créez votre fiche en 3 étapes. Notre équipe la vérifie avant sa publication.';

  @override
  String get badgeMasque => 'Masqué';

  @override
  String get badgeRupture => 'En rupture';

  @override
  String get catalogue => 'Catalogue';

  @override
  String get catalogueVideTitre => 'Votre catalogue est vide';

  @override
  String get catalogueVideTexte =>
      'Ajoutez vos produits ou services avec leur prix pour les présenter à vos clients.';

  @override
  String get categorieMagasin => 'Magasin';

  @override
  String get categorieRestaurant => 'Restaurant';

  @override
  String get categorieLogement => 'Logement';

  @override
  String get categorieService => 'Service';

  @override
  String get champAdresse => 'Adresse';

  @override
  String get champCategorie => 'Catégorie';

  @override
  String get champDescription => 'Description';

  @override
  String get champDevise => 'Devise';

  @override
  String get champHoraires => 'Horaires d\'ouverture';

  @override
  String get champNomCommerce => 'Nom du commerce';

  @override
  String get champNomProduit => 'Nom du produit';

  @override
  String get champObligatoire => 'Ce champ est obligatoire.';

  @override
  String get champPays => 'Pays';

  @override
  String get champPrix => 'Prix';

  @override
  String get champTelephone => 'Téléphone';

  @override
  String get champVille => 'Ville';

  @override
  String get charteTitre => 'Charte chrétienne';

  @override
  String get charteTexteProvisoire =>
      'Le texte de la charte chrétienne sera bientôt disponible. En l\'acceptant, vous vous engagez à en respecter les principes dans la gestion de votre commerce.';

  @override
  String get charteJAccepte => 'J\'ai lu et j\'accepte la charte';

  @override
  String get charteAcceptee => 'Charte acceptée';

  @override
  String get creerFiche => 'Créer la fiche de mon commerce';

  @override
  String get enregistrer => 'Enregistrer';

  @override
  String get envoyerPourVerification => 'Envoyer pour vérification';

  @override
  String get erreurEnregistrement =>
      'L\'enregistrement a échoué. Vérifiez votre connexion et réessayez.';

  @override
  String get etapeInfos => 'Votre commerce';

  @override
  String get etapeLabels => 'Labels';

  @override
  String get etapePhotos => 'Photos';

  @override
  String etapeXsurY(int etape, int total) {
    return 'Étape $etape sur $total';
  }

  @override
  String get ferme => 'Fermé';

  @override
  String get ficheEnregistree => 'Fiche enregistrée.';

  @override
  String get ficheEnvoyee =>
      'Merci ! Votre fiche a été envoyée. Elle sera visible dès que notre équipe l\'aura vérifiée.';

  @override
  String get jourLundi => 'Lundi';

  @override
  String get jourMardi => 'Mardi';

  @override
  String get jourMercredi => 'Mercredi';

  @override
  String get jourJeudi => 'Jeudi';

  @override
  String get jourVendredi => 'Vendredi';

  @override
  String get jourSamedi => 'Samedi';

  @override
  String get jourDimanche => 'Dimanche';

  @override
  String get labelsExplication =>
      'Demandez les labels qui correspondent à votre commerce. Notre équipe les vérifie avant de les afficher.';

  @override
  String get labelsModifiablesAdmin =>
      'Les labels sont attribués par l\'équipe Harambee. Contactez-nous pour les modifier.';

  @override
  String get labelAfricainDetail =>
      'Commerce tenu par des personnes d\'origine africaine ou proposant des produits africains.';

  @override
  String get labelChretienDetail =>
      'Commerce tenu par des chrétiens engagés à respecter la charte chrétienne.';

  @override
  String get lireCharte => 'Lire et accepter la charte';

  @override
  String get localisationDesactivee =>
      'La localisation est désactivée. Activez-la dans les réglages du téléphone.';

  @override
  String get localisationRefusee =>
      'Harambee n\'a pas accès à votre position. Autorisez-la dans les réglages du téléphone.';

  @override
  String get localisationIndisponible =>
      'Position introuvable. Réessayez à l\'extérieur ou plus tard.';

  @override
  String get marquerDisponible => 'Marquer disponible';

  @override
  String get marquerRupture => 'Marquer en rupture';

  @override
  String get masquer => 'Masquer';

  @override
  String get modifier => 'Modifier';

  @override
  String get modifierFiche => 'Modifier la fiche';

  @override
  String get modifierProduit => 'Modifier le produit';

  @override
  String get monCommerce => 'Mon commerce';

  @override
  String get photoCamera => 'Prendre une photo';

  @override
  String get photoGalerie => 'Choisir dans la galerie';

  @override
  String photosAide(int max) {
    return 'Ajoutez jusqu\'à $max photos : la devanture, l\'intérieur, vos produits. Une première photo claire attire plus de clients.';
  }

  @override
  String get positionAbsente => 'Enregistrer la position du commerce';

  @override
  String get positionEnregistree => 'Position enregistrée';

  @override
  String get positionAide =>
      'Touchez ici depuis votre commerce pour apparaître dans les recherches « près de moi ».';

  @override
  String get precedent => 'Précédent';

  @override
  String get produitIntrouvable => 'Ce produit n\'existe plus.';

  @override
  String get produitVisible => 'Visible par les clients';

  @override
  String get produitVisibleAide =>
      'Désactivez pour masquer le produit sans le supprimer.';

  @override
  String get retirerPhoto => 'Retirer la photo';

  @override
  String get statutEnVerification => 'En vérification';

  @override
  String get statutEnVerificationAide =>
      'Notre équipe vérifie votre fiche. Vous pouvez déjà préparer votre catalogue.';

  @override
  String get statutPublie => 'Publié';

  @override
  String get statutPublieAide =>
      'Votre fiche est visible par tous les clients.';

  @override
  String get statutSuspendu => 'Suspendu';

  @override
  String get statutSuspenduAide =>
      'Votre fiche n\'est plus visible. Contactez-nous pour en savoir plus.';

  @override
  String statutSuspenduMotif(String motif) {
    return 'Votre fiche n\'est plus visible. Motif : $motif';
  }

  @override
  String get suivant => 'Suivant';

  @override
  String get supprimer => 'Supprimer';

  @override
  String get supprimerProduitTitre => 'Supprimer ce produit ?';

  @override
  String supprimerProduitTexte(String nom) {
    return '« $nom » sera définitivement supprimé. Pour le cacher temporairement, utilisez plutôt « Masquer ».';
  }

  @override
  String get validationCategorie => 'Choisissez une catégorie.';

  @override
  String get validationCharte =>
      'Pour demander le label « Chrétien », acceptez d\'abord la charte.';

  @override
  String get validationPrix => 'Indiquez un prix valide (ex. 8,50).';

  @override
  String get valider => 'Valider';

  @override
  String get vousAvezUnCommerce => 'Vous avez un commerce ?';

  @override
  String get vousAvezUnCommerceAide =>
      'Passez en compte professionnel pour le présenter sur Harambee.';
}
