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
  String get chargement => 'Loading';

  @override
  String get actions => 'Actions';

  @override
  String get afficher => 'Show';

  @override
  String get ajouterPhoto => 'Add a photo';

  @override
  String get ajouterProduit => 'Add a product';

  @override
  String get annuler => 'Cancel';

  @override
  String get aucunCommerceTitre => 'Showcase your business';

  @override
  String get aucunCommerceTexte =>
      'Create your page in 3 steps. Our team checks it before it goes live.';

  @override
  String get badgeMasque => 'Hidden';

  @override
  String get badgeRupture => 'Out of stock';

  @override
  String get catalogue => 'Catalog';

  @override
  String get catalogueVideTitre => 'Your catalog is empty';

  @override
  String get catalogueVideTexte =>
      'Add your products or services with their prices to show them to your customers.';

  @override
  String get categorieMagasin => 'Shop';

  @override
  String get categorieRestaurant => 'Restaurant';

  @override
  String get categorieLogement => 'Housing';

  @override
  String get categorieService => 'Service';

  @override
  String get champAdresse => 'Address';

  @override
  String get champCategorie => 'Category';

  @override
  String get champDescription => 'Description';

  @override
  String get champDevise => 'Currency';

  @override
  String get champHoraires => 'Opening hours';

  @override
  String get champNomCommerce => 'Business name';

  @override
  String get champNomProduit => 'Product name';

  @override
  String get champObligatoire => 'This field is required.';

  @override
  String get champPays => 'Country';

  @override
  String get champPrix => 'Price';

  @override
  String get champTelephone => 'Phone';

  @override
  String get champVille => 'City';

  @override
  String get charteTitre => 'Christian charter';

  @override
  String get charteTexteProvisoire =>
      'The text of the Christian charter will be available soon. By accepting it, you commit to respecting its principles in running your business.';

  @override
  String get charteJAccepte => 'I have read and accept the charter';

  @override
  String get charteAcceptee => 'Charter accepted';

  @override
  String get creerFiche => 'Create my business page';

  @override
  String get enregistrer => 'Save';

  @override
  String get envoyerPourVerification => 'Submit for review';

  @override
  String get erreurEnregistrement =>
      'Saving failed. Check your connection and try again.';

  @override
  String get etapeInfos => 'Your business';

  @override
  String get etapeLabels => 'Labels';

  @override
  String get etapePhotos => 'Photos';

  @override
  String etapeXsurY(int etape, int total) {
    return 'Step $etape of $total';
  }

  @override
  String get ferme => 'Closed';

  @override
  String get ficheEnregistree => 'Page saved.';

  @override
  String get ficheEnvoyee =>
      'Thank you! Your page has been submitted. It will be visible once our team has reviewed it.';

  @override
  String get jourLundi => 'Monday';

  @override
  String get jourMardi => 'Tuesday';

  @override
  String get jourMercredi => 'Wednesday';

  @override
  String get jourJeudi => 'Thursday';

  @override
  String get jourVendredi => 'Friday';

  @override
  String get jourSamedi => 'Saturday';

  @override
  String get jourDimanche => 'Sunday';

  @override
  String get labelsExplication =>
      'Request the labels that fit your business. Our team checks them before displaying them.';

  @override
  String get labelsModifiablesAdmin =>
      'Labels are granted by the Harambee team. Contact us to change them.';

  @override
  String get labelAfricainDetail =>
      'Business run by people of African origin or offering African products.';

  @override
  String get labelChretienDetail =>
      'Business run by Christians committed to the Christian charter.';

  @override
  String get lireCharte => 'Read and accept the charter';

  @override
  String get localisationDesactivee =>
      'Location is turned off. Turn it on in your phone settings.';

  @override
  String get localisationRefusee =>
      'Harambee can\'t access your location. Allow it in your phone settings.';

  @override
  String get localisationIndisponible =>
      'Location unavailable. Try again outside or later.';

  @override
  String get marquerDisponible => 'Mark as available';

  @override
  String get marquerRupture => 'Mark as out of stock';

  @override
  String get masquer => 'Hide';

  @override
  String get modifier => 'Edit';

  @override
  String get modifierFiche => 'Edit page';

  @override
  String get modifierProduit => 'Edit product';

  @override
  String get monCommerce => 'My business';

  @override
  String get photoCamera => 'Take a photo';

  @override
  String get photoGalerie => 'Choose from gallery';

  @override
  String photosAide(int max) {
    return 'Add up to $max photos: storefront, interior, products. A clear first photo attracts more customers.';
  }

  @override
  String get positionAbsente => 'Save the business location';

  @override
  String get positionEnregistree => 'Location saved';

  @override
  String get positionAide =>
      'Tap here from your business to appear in \"near me\" searches.';

  @override
  String get precedent => 'Back';

  @override
  String get produitIntrouvable => 'This product no longer exists.';

  @override
  String get produitVisible => 'Visible to customers';

  @override
  String get produitVisibleAide =>
      'Turn off to hide the product without deleting it.';

  @override
  String get retirerPhoto => 'Remove photo';

  @override
  String get statutEnVerification => 'Under review';

  @override
  String get statutEnVerificationAide =>
      'Our team is reviewing your page. You can already prepare your catalog.';

  @override
  String get statutPublie => 'Published';

  @override
  String get statutPublieAide => 'Your page is visible to all customers.';

  @override
  String get statutSuspendu => 'Suspended';

  @override
  String get statutSuspenduAide =>
      'Your page is no longer visible. Contact us to learn more.';

  @override
  String statutSuspenduMotif(String motif) {
    return 'Your page is no longer visible. Reason: $motif';
  }

  @override
  String get suivant => 'Next';

  @override
  String get supprimer => 'Delete';

  @override
  String get supprimerProduitTitre => 'Delete this product?';

  @override
  String supprimerProduitTexte(String nom) {
    return '\"$nom\" will be permanently deleted. To hide it temporarily, use \"Hide\" instead.';
  }

  @override
  String get validationCategorie => 'Choose a category.';

  @override
  String get validationCharte =>
      'To request the \"Christian\" label, first accept the charter.';

  @override
  String get validationPrix => 'Enter a valid price (e.g. 8.50).';

  @override
  String get valider => 'Confirm';

  @override
  String get vousAvezUnCommerce => 'Do you own a business?';

  @override
  String get vousAvezUnCommerceAide =>
      'Switch to a business account to showcase it on Harambee.';

  @override
  String get activerAdminTitre => 'Enable administrator access?';

  @override
  String get activerAdminTexte =>
      'Reserved for the Harambee manager. Only the account designated at setup can become the first administrator.';

  @override
  String get adminActive =>
      'You are now an administrator. The Admin tab is available.';

  @override
  String get adminAucunCommerce => 'No businesses here yet.';

  @override
  String get adminAucunSignalement => 'No reports to handle.';

  @override
  String get adminEnAttente => 'Pending';

  @override
  String get adminPublies => 'Published';

  @override
  String get adminSuspendus => 'Suspended';

  @override
  String get adminSignalements => 'Reports';

  @override
  String get adminRienAVerifier => 'Everything is reviewed!';

  @override
  String adminNomme(String email) {
    return '$email is now an administrator. They must sign out and back in.';
  }

  @override
  String adminRetire(String email) {
    return '$email is no longer an administrator.';
  }

  @override
  String get administrateurs => 'Administrators';

  @override
  String get administrateursAide =>
      'Enter the email of an existing Harambee account to grant or remove administrator access.';

  @override
  String get aucunePhoto => 'No photos.';

  @override
  String get charteNonSignee => 'Christian charter not signed';

  @override
  String charteSigneeLe(String date) {
    return 'Charter signed on $date';
  }

  @override
  String get cibleCommerce => 'Reported business';

  @override
  String get cibleAvis => 'Reported review';

  @override
  String get cibleMessage => 'Reported message';

  @override
  String get commerceIntrouvable => 'This business no longer exists.';

  @override
  String get enregistrerLabels => 'Save labels';

  @override
  String get erreurAdminNonAutorise =>
      'This account is not allowed to do this.';

  @override
  String get erreurAdminCompteIntrouvable =>
      'No Harambee account with this email.';

  @override
  String get erreurAdminDejaDesigne =>
      'The first administrator has already been designated.';

  @override
  String get erreurAdminSoiMeme => 'You cannot remove your own access.';

  @override
  String get fichePubliee => 'Page published.';

  @override
  String get ficheRefusee => 'Page rejected. The owner will see the reason.';

  @override
  String get ficheSuspendue => 'Page suspended.';

  @override
  String get labelsAConfirmer => 'Labels';

  @override
  String get labelsAConfirmerAide =>
      'Requested by the owner. Confirm or remove them before publishing.';

  @override
  String get labelsEnregistres => 'Labels saved.';

  @override
  String get marquerTraite => 'Mark as handled';

  @override
  String get motif => 'Reason';

  @override
  String get motifAide => 'It will be shown to the owner in their space.';

  @override
  String motifActuel(String motif) {
    return 'Reason: $motif';
  }

  @override
  String get nommerAdmin => 'Make administrator';

  @override
  String get retirerAdmin => 'Remove administrator access';

  @override
  String get positionGps => 'GPS location';

  @override
  String get positionNonRenseignee =>
      'Not set: the business won\'t appear in distance search.';

  @override
  String get publierFiche => 'Publish page';

  @override
  String get refuserFiche => 'Reject';

  @override
  String get republierFiche => 'Republish page';

  @override
  String get suspendreFiche => 'Suspend page';

  @override
  String get voirCommerce => 'View business';

  @override
  String get ajouterFavori => 'Add to favorites';

  @override
  String get retirerFavori => 'Remove from favorites';

  @override
  String get anonyme => 'Anonymous';

  @override
  String get appeler => 'Call';

  @override
  String get itineraire => 'Directions';

  @override
  String get envoyerMessage => 'Message';

  @override
  String get aucunAvis => 'No reviews yet. Be the first!';

  @override
  String get aucunProduitPublic =>
      'This business hasn\'t published any products yet.';

  @override
  String get aucunResultatTitre => 'No results';

  @override
  String get aucunResultatTexte => 'Try another word or remove some filters.';

  @override
  String get choisirNote => 'Choose a rating from 1 to 5 stars.';

  @override
  String get continent => 'Continent';

  @override
  String get continentEurope => 'Europe';

  @override
  String get continentAfrique => 'Africa';

  @override
  String get continentAmerique => 'Americas';

  @override
  String get donnerAvisTitre => 'Do you know this business?';

  @override
  String get donnerAvis => 'Write a review';

  @override
  String get monAvis => 'My review';

  @override
  String get modifierMonAvis => 'Edit my review';

  @override
  String get votreAvis => 'Your review (optional)';

  @override
  String get publierAvis => 'Post';

  @override
  String get effacerRecherche => 'Clear search';

  @override
  String get fermeMaintenant => 'Closed';

  @override
  String get ouvert => 'Open';

  @override
  String get ouvertMaintenant => 'Open now';

  @override
  String get filtres => 'Filters';

  @override
  String get horairesNonRenseignes => 'Opening hours not provided.';

  @override
  String get ongletProduits => 'Products';

  @override
  String get ongletAvis => 'Reviews';

  @override
  String get ongletInfos => 'Info';

  @override
  String get rechercherIndice => 'A business, a city…';

  @override
  String get reinitialiser => 'Reset';

  @override
  String get voirResultats => 'Show results';

  @override
  String get voirPlus => 'Show more';

  @override
  String get tous => 'All';

  @override
  String get signaler => 'Report';

  @override
  String get signalerAide =>
      'Explain the problem. Our team will review your report.';

  @override
  String get signalementEnvoye =>
      'Thank you. Our team will review this report.';

  @override
  String nEtoiles(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String noteSur5(String note, int nb) {
    String _temp0 = intl.Intl.pluralLogic(
      nb,
      locale: localeName,
      other: '$nb reviews',
      one: '1 review',
    );
    return 'Rated $note out of 5, $_temp0';
  }

  @override
  String get ajusterPosition => 'Adjust on the map';

  @override
  String get ajusterPositionAide =>
      'Tap the map at the exact location of your business, or drag the pin.';

  @override
  String get validerPosition => 'Confirm this location';

  @override
  String get presDeMoi => 'Near me';

  @override
  String get rayon => 'Search radius';

  @override
  String rayonKm(int km) {
    return '$km km';
  }

  @override
  String aucunCommerceProche(int km) {
    return 'No business within $km km';
  }

  @override
  String get aucunCommerceProcheAide =>
      'Increase the radius or remove some filters.';

  @override
  String get vueCarte => 'Show map';

  @override
  String get vueListe => 'Show list';

  @override
  String get apercuPhoto => '📷 Photo';

  @override
  String get conversationIntrouvable => 'This conversation no longer exists.';

  @override
  String get ecrireMessage => 'Write a message…';

  @override
  String get envoyer => 'Send';

  @override
  String get envoyerPhoto => 'Send a photo';

  @override
  String get erreurEnvoiMessage =>
      'Message not sent. Check your connection and try again.';

  @override
  String messagesNonLus(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unread messages',
      one: '1 unread message',
    );
    return '$_temp0';
  }

  @override
  String get photoEnvoyee => 'Photo sent in the conversation';

  @override
  String get premierMessageTitre => 'Say hello!';

  @override
  String get premierMessageTexte =>
      'Ask your questions: availability, hours, orders… The business will reply here.';

  @override
  String get accepterEspeces => 'Accept cash';

  @override
  String get accepterEspecesAide =>
      'The customer pays cash on delivery or pickup.';

  @override
  String get actionAccepter => 'Accept order';

  @override
  String get actionPreparer => 'Start preparing';

  @override
  String get actionPrete => 'Order ready';

  @override
  String get actionEnLivraison => 'Out for delivery';

  @override
  String get actionLivree => 'Order delivered';

  @override
  String get actionRetiree => 'Order picked up';

  @override
  String get activerCommande => 'Enable online ordering';

  @override
  String get activerCommandeAide =>
      'Your customers will be able to order your products in the app.';

  @override
  String get commandeActiveModifier => 'Ordering and delivery';

  @override
  String get commandeEtLivraison => 'Ordering and delivery';

  @override
  String get adresseLivraison => 'Delivery address';

  @override
  String get ajouterTarifPays => 'Add a country rate';

  @override
  String get ajouterAuPanier => 'Add to cart';

  @override
  String get annulerCommande => 'Cancel order';

  @override
  String get annulerCommandeTitre => 'Cancel this order?';

  @override
  String get annulerCommandeTexte =>
      'The business will be notified. This cannot be undone.';

  @override
  String get aucuneCommande => 'No orders';

  @override
  String get aucuneCommandeProAide =>
      'Enable online ordering in \"Ordering and delivery\" to receive orders.';

  @override
  String get aucuneDate => 'No date';

  @override
  String get augmenter => 'Add one';

  @override
  String get diminuer => 'Remove one';

  @override
  String get retirer => 'Remove from cart';

  @override
  String get cmdNouvelle => 'Order sent';

  @override
  String get cmdAcceptee => 'Accepted';

  @override
  String get cmdEnPreparation => 'Being prepared';

  @override
  String get cmdPrete => 'Ready';

  @override
  String get cmdEnLivraison => 'Out for delivery';

  @override
  String get cmdLivree => 'Delivered';

  @override
  String get cmdRetiree => 'Picked up';

  @override
  String get cmdRefusee => 'Declined';

  @override
  String get cmdAnnulee => 'Cancelled';

  @override
  String get commandeIntrouvable => 'This order doesn\'t exist.';

  @override
  String commandeNumero(String numero) {
    return 'Order $numero';
  }

  @override
  String commanderMontant(String montant) {
    return 'Order · $montant';
  }

  @override
  String get commandes => 'Orders';

  @override
  String get mesCommandes => 'My orders';

  @override
  String get commission => 'Commission';

  @override
  String get commissionLancement => 'Launch commission';

  @override
  String get delaiPreparation => 'Preparation time';

  @override
  String get dureeLancement => 'Duration';

  @override
  String get mois => 'months';

  @override
  String get enCours => 'Ongoing';

  @override
  String get terminees => 'Completed';

  @override
  String encoreXPourMinimum(String montant) {
    return '$montant more to reach the minimum order';
  }

  @override
  String get erreurCommandeFermee =>
      'This business isn\'t taking orders right now.';

  @override
  String get erreurHorsZone =>
      'Your address is outside the delivery area. Choose \"Pickup\".';

  @override
  String get erreurPaiementIndisponible =>
      'No payment method available for this business.';

  @override
  String get erreurProduitIndisponible =>
      'An item in your cart is no longer available. Remove it and try again.';

  @override
  String get erreurTarifsManquants =>
      'Online ordering isn\'t open yet. Please try again later.';

  @override
  String especesAEncaisser(String montant) {
    return 'To collect in cash: $montant';
  }

  @override
  String get especesLivraison => 'Cash on delivery';

  @override
  String get especesRetrait => 'Cash on pickup';

  @override
  String get paiementEspeces => 'Cash';

  @override
  String get fraisFixes => 'Fixed amount';

  @override
  String get fraisPourcentage => 'Percentage';

  @override
  String get fraisLivraison => 'Delivery fee';

  @override
  String get fraisPaiement => 'Payment fees';

  @override
  String get fraisService => 'Service fee';

  @override
  String get fraisServiceAide =>
      'This fee keeps Harambee running, which stays far cheaper than the big delivery platforms.';

  @override
  String get fraisServicePlateforme => 'Service fee (Harambee)';

  @override
  String get inscritsAvant => 'For businesses registered before';

  @override
  String get instructionsLivraison => 'Instructions (floor, code…)';

  @override
  String get livraisonGratuiteDes => 'Free delivery from';

  @override
  String get livraisonGratuiteAide =>
      'Leave empty if delivery is always charged.';

  @override
  String get minimumCommande => 'Minimum order';

  @override
  String get minimumCommandeAide => 'Minimum cart amount, delivery or pickup.';

  @override
  String get minimumLivraison => 'Minimum for delivery';

  @override
  String get modeEmporter => 'Pickup';

  @override
  String get modeLivraison => 'Delivery';

  @override
  String get modeLivraisonAide =>
      'You deliver yourself or with your own driver.';

  @override
  String get modesCommande => 'Options offered';

  @override
  String get montantConfirmeServeur =>
      'The final amount is confirmed when you order.';

  @override
  String get montantNet => 'Net amount for you';

  @override
  String get motifRefusCommandeAide => 'The customer will see this reason.';

  @override
  String get non => 'No';

  @override
  String nouvellesCommandes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n new orders',
      one: '1 new order',
    );
    return '$_temp0';
  }

  @override
  String get offerte => 'Free';

  @override
  String get paiement => 'Payment';

  @override
  String get paiementCarte => 'Card or Bancontact';

  @override
  String get paiementCarteActif => 'Enabled: your customers can pay by card.';

  @override
  String get paiementCarteBientot => 'Coming soon.';

  @override
  String get panier => 'Cart';

  @override
  String panierDe(String nom) {
    return 'Cart · $nom';
  }

  @override
  String get panierVide => 'Your cart is empty';

  @override
  String voirPanier(int n, String montant) {
    return 'View cart ($n) · $montant';
  }

  @override
  String get payeParClient => 'Paid by the customer';

  @override
  String get periodeLancement => 'Launch period';

  @override
  String get periodeLancementAide =>
      'Reduced commission for a few months for the first registered businesses.';

  @override
  String get plafond => 'Cap (optional)';

  @override
  String get positionLivraison => 'Save my location for delivery';

  @override
  String positionLivraisonAide(String km) {
    return 'The business delivers within $km km.';
  }

  @override
  String get positionLivraisonRequise =>
      'Save your location to check you are within the delivery area.';

  @override
  String get pourVotreCommerce => 'For your business';

  @override
  String get rayonLivraison => 'Delivery radius';

  @override
  String get refuserCommande => 'Decline order';

  @override
  String get reglagesEnregistres => 'Settings saved.';

  @override
  String get sousTotal => 'Subtotal';

  @override
  String get tarifParDefaut => 'Default rate';

  @override
  String get tarifs => 'Rates';

  @override
  String get tarifsAide =>
      'Commission on the subtotal (never on delivery) and service fee paid by the customer. A country rate replaces the default rate.';

  @override
  String get tarifsEnregistres => 'Rates saved.';

  @override
  String get telephoneCommandeAide =>
      'The business may call you about the order.';

  @override
  String get total => 'Total';

  @override
  String get totalVentes => 'Total sales';

  @override
  String get validationModes =>
      'Choose at least one option: delivery or pickup.';
}
