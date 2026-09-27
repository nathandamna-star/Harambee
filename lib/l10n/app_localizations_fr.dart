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

  @override
  String get activerAdminTitre => 'Activer l\'accès administrateur ?';

  @override
  String get activerAdminTexte =>
      'Réservé au responsable de Harambee. Seul le compte désigné lors de la mise en service peut devenir le premier administrateur.';

  @override
  String get adminActive =>
      'Vous êtes maintenant administrateur. L\'onglet Admin est disponible.';

  @override
  String get adminAucunCommerce => 'Aucun commerce ici pour l\'instant.';

  @override
  String get adminAucunSignalement => 'Aucun signalement à traiter.';

  @override
  String get adminEnAttente => 'En attente';

  @override
  String get adminPublies => 'Publiés';

  @override
  String get adminSuspendus => 'Suspendus';

  @override
  String get adminSignalements => 'Signalements';

  @override
  String get adminRienAVerifier => 'Tout est vérifié !';

  @override
  String adminNomme(String email) {
    return '$email est maintenant administrateur. Il doit se déconnecter puis se reconnecter.';
  }

  @override
  String adminRetire(String email) {
    return '$email n\'est plus administrateur.';
  }

  @override
  String get administrateurs => 'Administrateurs';

  @override
  String get administrateursAide =>
      'Saisissez l\'adresse e-mail d\'un compte Harambee existant pour lui donner ou lui retirer l\'accès administrateur.';

  @override
  String get aucunePhoto => 'Aucune photo.';

  @override
  String get charteNonSignee => 'Charte chrétienne non signée';

  @override
  String charteSigneeLe(String date) {
    return 'Charte signée le $date';
  }

  @override
  String get cibleCommerce => 'Commerce signalé';

  @override
  String get cibleAvis => 'Avis signalé';

  @override
  String get cibleMessage => 'Message signalé';

  @override
  String get commerceIntrouvable => 'Ce commerce n\'existe plus.';

  @override
  String get enregistrerLabels => 'Enregistrer les labels';

  @override
  String get erreurAdminNonAutorise =>
      'Ce compte n\'est pas autorisé à faire cette action.';

  @override
  String get erreurAdminCompteIntrouvable =>
      'Aucun compte Harambee avec cette adresse e-mail.';

  @override
  String get erreurAdminDejaDesigne =>
      'Le premier administrateur a déjà été désigné.';

  @override
  String get erreurAdminSoiMeme =>
      'Vous ne pouvez pas retirer votre propre accès.';

  @override
  String get fichePubliee => 'Fiche publiée.';

  @override
  String get ficheRefusee => 'Fiche refusée. Le commerçant verra le motif.';

  @override
  String get ficheSuspendue => 'Fiche suspendue.';

  @override
  String get labelsAConfirmer => 'Labels';

  @override
  String get labelsAConfirmerAide =>
      'Demandés par le commerçant. Confirmez ou retirez-les avant de publier.';

  @override
  String get labelsEnregistres => 'Labels enregistrés.';

  @override
  String get marquerTraite => 'Marquer comme traité';

  @override
  String get motif => 'Motif';

  @override
  String get motifAide => 'Il sera affiché au commerçant dans son espace.';

  @override
  String motifActuel(String motif) {
    return 'Motif : $motif';
  }

  @override
  String get nommerAdmin => 'Nommer administrateur';

  @override
  String get retirerAdmin => 'Retirer l\'accès administrateur';

  @override
  String get positionGps => 'Position GPS';

  @override
  String get positionNonRenseignee =>
      'Non renseignée : le commerce n\'apparaîtra pas dans la recherche par distance.';

  @override
  String get publierFiche => 'Publier la fiche';

  @override
  String get refuserFiche => 'Refuser';

  @override
  String get republierFiche => 'Republier la fiche';

  @override
  String get suspendreFiche => 'Suspendre la fiche';

  @override
  String get voirCommerce => 'Voir le commerce';

  @override
  String get ajouterFavori => 'Ajouter aux favoris';

  @override
  String get retirerFavori => 'Retirer des favoris';

  @override
  String get anonyme => 'Anonyme';

  @override
  String get appeler => 'Appeler';

  @override
  String get itineraire => 'Itinéraire';

  @override
  String get envoyerMessage => 'Message';

  @override
  String get aucunAvis => 'Aucun avis pour l\'instant. Soyez le premier !';

  @override
  String get aucunProduitPublic =>
      'Ce commerce n\'a pas encore publié de produits.';

  @override
  String get aucunResultatTitre => 'Aucun résultat';

  @override
  String get aucunResultatTexte =>
      'Essayez un autre mot ou retirez des filtres.';

  @override
  String get choisirNote => 'Choisissez une note de 1 à 5 étoiles.';

  @override
  String get continent => 'Continent';

  @override
  String get continentEurope => 'Europe';

  @override
  String get continentAfrique => 'Afrique';

  @override
  String get continentAmerique => 'Amérique';

  @override
  String get donnerAvisTitre => 'Vous connaissez ce commerce ?';

  @override
  String get donnerAvis => 'Donner mon avis';

  @override
  String get monAvis => 'Mon avis';

  @override
  String get modifierMonAvis => 'Modifier mon avis';

  @override
  String get votreAvis => 'Votre avis (facultatif)';

  @override
  String get publierAvis => 'Publier';

  @override
  String get effacerRecherche => 'Effacer la recherche';

  @override
  String get fermeMaintenant => 'Fermé';

  @override
  String get ouvert => 'Ouvert';

  @override
  String get ouvertMaintenant => 'Ouvert maintenant';

  @override
  String get filtres => 'Filtres';

  @override
  String get horairesNonRenseignes => 'Horaires non renseignés.';

  @override
  String get ongletProduits => 'Produits';

  @override
  String get ongletAvis => 'Avis';

  @override
  String get ongletInfos => 'Infos';

  @override
  String get rechercherIndice => 'Un commerce, une ville…';

  @override
  String get reinitialiser => 'Réinitialiser';

  @override
  String get voirResultats => 'Voir les résultats';

  @override
  String get voirPlus => 'Voir plus';

  @override
  String get tous => 'Tous';

  @override
  String get signaler => 'Signaler';

  @override
  String get signalerAide =>
      'Expliquez ce qui pose problème. Notre équipe examinera votre signalement.';

  @override
  String get signalementEnvoye =>
      'Merci. Notre équipe va examiner ce signalement.';

  @override
  String nEtoiles(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String noteSur5(String note, int nb) {
    String _temp0 = intl.Intl.pluralLogic(
      nb,
      locale: localeName,
      other: '$nb avis',
      one: '1 avis',
    );
    return 'Note $note sur 5, $_temp0';
  }

  @override
  String get ajusterPosition => 'Ajuster sur la carte';

  @override
  String get ajusterPositionAide =>
      'Touchez la carte à l\'emplacement exact de votre commerce, ou faites glisser le repère.';

  @override
  String get validerPosition => 'Valider cette position';

  @override
  String get presDeMoi => 'Près de moi';

  @override
  String get rayon => 'Rayon de recherche';

  @override
  String rayonKm(int km) {
    return '$km km';
  }

  @override
  String aucunCommerceProche(int km) {
    return 'Aucun commerce à moins de $km km';
  }

  @override
  String get aucunCommerceProcheAide =>
      'Agrandissez le rayon ou retirez des filtres.';

  @override
  String get vueCarte => 'Voir sur la carte';

  @override
  String get vueListe => 'Voir la liste';

  @override
  String get apercuPhoto => '📷 Photo';

  @override
  String get conversationIntrouvable => 'Cette conversation n\'existe plus.';

  @override
  String get ecrireMessage => 'Écrire un message…';

  @override
  String get envoyer => 'Envoyer';

  @override
  String get envoyerPhoto => 'Envoyer une photo';

  @override
  String get erreurEnvoiMessage =>
      'Message non envoyé. Vérifiez votre connexion et réessayez.';

  @override
  String messagesNonLus(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n messages non lus',
      one: '1 message non lu',
    );
    return '$_temp0';
  }

  @override
  String get photoEnvoyee => 'Photo envoyée dans la conversation';

  @override
  String get premierMessageTitre => 'Dites bonjour !';

  @override
  String get premierMessageTexte =>
      'Posez vos questions : disponibilité, horaires, commande… Le commerçant vous répondra ici.';

  @override
  String get accepterEspeces => 'Accepter les espèces';

  @override
  String get accepterEspecesAide =>
      'Le client paie en espèces à la livraison ou au retrait.';

  @override
  String get actionAccepter => 'Accepter la commande';

  @override
  String get actionPreparer => 'Commencer la préparation';

  @override
  String get actionPrete => 'Commande prête';

  @override
  String get actionEnLivraison => 'Partir en livraison';

  @override
  String get actionLivree => 'Commande livrée';

  @override
  String get actionRetiree => 'Commande retirée';

  @override
  String get activerCommande => 'Activer la commande en ligne';

  @override
  String get activerCommandeAide =>
      'Vos clients pourront commander vos produits dans l\'app.';

  @override
  String get commandeActiveModifier => 'Commande et livraison';

  @override
  String get commandeEtLivraison => 'Commande et livraison';

  @override
  String get adresseLivraison => 'Adresse de livraison';

  @override
  String get ajouterTarifPays => 'Ajouter un tarif pour un pays';

  @override
  String get ajouterAuPanier => 'Ajouter au panier';

  @override
  String get annulerCommande => 'Annuler la commande';

  @override
  String get annulerCommandeTitre => 'Annuler cette commande ?';

  @override
  String get annulerCommandeTexte =>
      'Le commerce sera prévenu. Vous ne pourrez plus revenir en arrière.';

  @override
  String get aucuneCommande => 'Aucune commande';

  @override
  String get aucuneCommandeProAide =>
      'Activez la commande en ligne dans « Commande et livraison » pour recevoir des commandes.';

  @override
  String get aucuneDate => 'Aucune date';

  @override
  String get augmenter => 'Ajouter un';

  @override
  String get diminuer => 'Enlever un';

  @override
  String get retirer => 'Retirer du panier';

  @override
  String get cmdNouvelle => 'Commande envoyée';

  @override
  String get cmdAcceptee => 'Acceptée';

  @override
  String get cmdEnPreparation => 'En préparation';

  @override
  String get cmdPrete => 'Prête';

  @override
  String get cmdEnLivraison => 'En livraison';

  @override
  String get cmdLivree => 'Livrée';

  @override
  String get cmdRetiree => 'Retirée';

  @override
  String get cmdRefusee => 'Refusée';

  @override
  String get cmdAnnulee => 'Annulée';

  @override
  String get commandeIntrouvable => 'Cette commande n\'existe pas.';

  @override
  String commandeNumero(String numero) {
    return 'Commande $numero';
  }

  @override
  String commanderMontant(String montant) {
    return 'Commander · $montant';
  }

  @override
  String get commandes => 'Commandes';

  @override
  String get mesCommandes => 'Mes commandes';

  @override
  String get commission => 'Commission';

  @override
  String get commissionLancement => 'Commission pendant le lancement';

  @override
  String get delaiPreparation => 'Délai de préparation';

  @override
  String get dureeLancement => 'Durée';

  @override
  String get mois => 'mois';

  @override
  String get enCours => 'En cours';

  @override
  String get terminees => 'Terminées';

  @override
  String encoreXPourMinimum(String montant) {
    return 'Encore $montant pour atteindre le minimum de commande';
  }

  @override
  String get erreurCommandeFermee =>
      'Ce commerce ne prend pas de commande pour le moment.';

  @override
  String get erreurHorsZone =>
      'Votre adresse est hors de la zone de livraison. Choisissez « À emporter ».';

  @override
  String get erreurPaiementIndisponible =>
      'Aucun moyen de paiement disponible pour ce commerce.';

  @override
  String get erreurProduitIndisponible =>
      'Un produit de votre panier n\'est plus disponible. Retirez-le puis réessayez.';

  @override
  String get erreurTarifsManquants =>
      'La commande en ligne n\'est pas encore ouverte. Réessayez plus tard.';

  @override
  String especesAEncaisser(String montant) {
    return 'À encaisser en espèces : $montant';
  }

  @override
  String get especesLivraison => 'Espèces à la livraison';

  @override
  String get especesRetrait => 'Espèces au retrait';

  @override
  String get paiementEspeces => 'Espèces';

  @override
  String get fraisFixes => 'Montant fixe';

  @override
  String get fraisPourcentage => 'Pourcentage';

  @override
  String get fraisLivraison => 'Frais de livraison';

  @override
  String get fraisPaiement => 'Frais de paiement';

  @override
  String get fraisService => 'Frais de service';

  @override
  String get fraisServiceAide =>
      'Ces frais font vivre Harambee, qui reste bien moins chère que les grandes plateformes de livraison.';

  @override
  String get fraisServicePlateforme => 'Frais de service (Harambee)';

  @override
  String get inscritsAvant => 'Pour les commerces inscrits avant le';

  @override
  String get instructionsLivraison => 'Instructions (étage, code…)';

  @override
  String get livraisonGratuiteDes => 'Livraison offerte à partir de';

  @override
  String get livraisonGratuiteAide =>
      'Laissez vide si la livraison est toujours payante.';

  @override
  String get minimumCommande => 'Minimum de commande';

  @override
  String get minimumCommandeAide =>
      'Montant minimum du panier, livraison ou à emporter.';

  @override
  String get minimumLivraison => 'Minimum pour la livraison';

  @override
  String get modeEmporter => 'À emporter';

  @override
  String get modeLivraison => 'Livraison';

  @override
  String get modeLivraisonAide =>
      'Vous livrez vous-même ou avec votre livreur.';

  @override
  String get modesCommande => 'Modes proposés';

  @override
  String get montantConfirmeServeur =>
      'Le montant final est confirmé au moment de la commande.';

  @override
  String get montantNet => 'Montant net pour vous';

  @override
  String get motifRefusCommandeAide => 'Le client verra ce motif.';

  @override
  String get non => 'Non';

  @override
  String nouvellesCommandes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n nouvelles commandes',
      one: '1 nouvelle commande',
    );
    return '$_temp0';
  }

  @override
  String get offerte => 'Offerte';

  @override
  String get paiement => 'Paiement';

  @override
  String get paiementCarte => 'Carte bancaire ou Bancontact';

  @override
  String get paiementCarteActif =>
      'Activé : vos clients peuvent payer par carte.';

  @override
  String get panier => 'Panier';

  @override
  String panierDe(String nom) {
    return 'Panier · $nom';
  }

  @override
  String get panierVide => 'Votre panier est vide';

  @override
  String voirPanier(int n, String montant) {
    return 'Voir le panier ($n) · $montant';
  }

  @override
  String get payeParClient => 'Payé par le client';

  @override
  String get periodeLancement => 'Période de lancement';

  @override
  String get periodeLancementAide =>
      'Commission réduite pendant quelques mois pour les premiers commerces inscrits.';

  @override
  String get plafond => 'Plafond (facultatif)';

  @override
  String get positionLivraison => 'Enregistrer ma position pour la livraison';

  @override
  String positionLivraisonAide(String km) {
    return 'Le commerce livre dans un rayon de $km km.';
  }

  @override
  String get positionLivraisonRequise =>
      'Enregistrez votre position pour vérifier que vous êtes dans la zone de livraison.';

  @override
  String get pourVotreCommerce => 'Pour votre commerce';

  @override
  String get rayonLivraison => 'Rayon de livraison';

  @override
  String get refuserCommande => 'Refuser la commande';

  @override
  String get reglagesEnregistres => 'Réglages enregistrés.';

  @override
  String get sousTotal => 'Sous-total';

  @override
  String get tarifParDefaut => 'Tarif par défaut';

  @override
  String get tarifs => 'Tarifs';

  @override
  String get tarifsAide =>
      'Commission prélevée sur le sous-total (jamais sur la livraison) et frais de service payés par le client. Un tarif par pays remplace le tarif par défaut.';

  @override
  String get tarifsEnregistres => 'Tarifs enregistrés.';

  @override
  String get telephoneCommandeAide =>
      'Le commerce pourra vous appeler au sujet de la commande.';

  @override
  String get total => 'Total';

  @override
  String get totalVentes => 'Total des ventes';

  @override
  String get validationModes =>
      'Choisissez au moins un mode : livraison ou à emporter.';

  @override
  String get paiementNonTermine =>
      'Paiement non terminé. Vous pouvez payer depuis le suivi de la commande.';

  @override
  String etatPaiement(String etat) {
    return 'Paiement : $etat';
  }

  @override
  String get paiementEnAttente => 'en attente';

  @override
  String get paiementPaye => 'payé';

  @override
  String get paiementRembourse => 'remboursé';

  @override
  String get paiementEchoue => 'échoué';

  @override
  String get payerMaintenant => 'Payer maintenant';

  @override
  String get paiementCarteAide =>
      'Recevez les paiements par carte et Bancontact directement sur votre compte bancaire, via Stripe.';

  @override
  String get activerPaiementCarte => 'Activer le paiement par carte';

  @override
  String get fraisPaiementCarte => 'Frais de paiement par carte';

  @override
  String get fraisPaiementCarteAide =>
      'Estimation des frais du prestataire (Stripe), retenus au commerce sur chaque paiement par carte.';

  @override
  String get revenus => 'Revenus';

  @override
  String get anneePrecedente => 'Année précédente';

  @override
  String get anneeSuivante => 'Année suivante';

  @override
  String get tousLesPays => 'Tous les pays';

  @override
  String get aucunRevenu => 'Aucune commande terminée sur cette période.';

  @override
  String get revenusAbonnementsBientot =>
      'Les abonnements premium et les mises en avant apparaîtront ici quand ils seront disponibles.';

  @override
  String nCommandes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n commandes',
      one: '1 commande',
    );
    return '$_temp0';
  }

  @override
  String get commissions => 'Commissions';

  @override
  String get ecartFraisPaiement => 'Écart frais de paiement (retenus − réels)';

  @override
  String get totalRevenus => 'Revenu Harambee';

  @override
  String get aFacturerEspeces => 'À facturer (commandes en espèces)';

  @override
  String get recapitulatifMensuel => 'Récapitulatif mensuel';

  @override
  String get aucunRecap => 'Pas encore de récapitulatif';

  @override
  String get aucunRecapAide =>
      'Il apparaîtra dès votre première commande livrée ou retirée.';

  @override
  String get nbCommandesTerminees => 'Commandes terminées';

  @override
  String get dontLivraison => 'dont frais de livraison';

  @override
  String get verseParStripe => 'Versé par Stripe (cartes)';

  @override
  String get encaisseEspeces => 'Encaissé en espèces';

  @override
  String get duAHarambee => 'À régler à Harambee';

  @override
  String get duAHarambeeAide =>
      'Frais de service et commission des commandes payées en espèces, facturés en fin de mois.';

  @override
  String get telechargerCsv => 'Télécharger (tableur CSV)';

  @override
  String get csvDate => 'Date';

  @override
  String get csvNumero => 'Numéro';

  @override
  String get csvClient => 'Client';

  @override
  String get cgu => 'Conditions d\'utilisation';

  @override
  String get confidentialite => 'Politique de confidentialité';

  @override
  String get legalEnFrancais =>
      'Ce texte n\'existe pour l\'instant qu\'en français.';

  @override
  String get enContinuantVousAcceptez => 'En continuant, vous acceptez nos :';

  @override
  String get profilEtReglages => 'Profil et réglages';

  @override
  String get langue => 'Langue';

  @override
  String get langueAuto => 'Celle du téléphone';

  @override
  String get devisePreferee => 'Devise préférée';

  @override
  String get devisePrefereeAide =>
      'Les prix restent affichés dans la devise du commerce.';

  @override
  String get supprimerMonCompte => 'Supprimer mon compte';

  @override
  String get supprimerCompteTitre => 'Supprimer votre compte ?';

  @override
  String get supprimerCompteTexte =>
      'Votre profil, vos favoris, vos avis, vos messages et, si vous êtes commerçant, vos fiches et votre catalogue seront définitivement supprimés. Vos commandes passées sont conservées sans votre nom ni vos coordonnées, pour la comptabilité des commerces.';

  @override
  String get motConfirmationSuppression => 'SUPPRIMER';

  @override
  String tapezPourConfirmer(String mot) {
    return 'Tapez $mot pour confirmer';
  }

  @override
  String get supprimerDefinitivement => 'Supprimer définitivement';

  @override
  String get compteSupprime => 'Votre compte a été supprimé.';

  @override
  String get erreurSuppressionCommandes =>
      'Vous avez des commandes en cours. Attendez qu\'elles soient terminées ou annulez-les avant de supprimer votre compte.';

  @override
  String get donneesDemo => 'Données de démonstration';

  @override
  String get donneesDemoAide =>
      'Dix commerces fictifs à Bruxelles, avec produits et avis, pour les essais et les captures d\'écran. ⚠️ À supprimer avant le lancement.';

  @override
  String get chargerDemo => 'Charger';

  @override
  String get supprimerDemo => 'Tout supprimer';

  @override
  String demoChargee(int n) {
    return '$n commerces de démonstration chargés.';
  }

  @override
  String demoSupprimee(int n) {
    return '$n commerces de démonstration supprimés.';
  }
}
