/// Clé publiable Stripe (mode test : `pk_test_…`). Elle n'est pas secrète :
/// elle permet seulement d'afficher le formulaire de paiement. La clé secrète
/// reste sur le serveur (secret Firebase STRIPE_SECRET_KEY).
/// Vide : le paiement par carte est désactivé dans l'app.
const stripeClePublique = '';

/// Adresse de retour après une validation bancaire (Bancontact, 3-D Secure).
const stripeSchemaUrl = 'harambee';
