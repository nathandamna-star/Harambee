/// Clé publiable Stripe (mode test : `pk_test_…`). Elle n'est pas secrète :
/// elle permet seulement d'afficher le formulaire de paiement. La clé secrète
/// reste sur le serveur (secret Firebase STRIPE_SECRET_KEY).
/// Vide : le paiement par carte est désactivé dans l'app.
const stripeClePublique =
    'pk_test_51UKBToKe3rvZDoUJt7JanT1X8xzXjWTbTiIIiCb1ExeO6jIRHQPG4OeGSWxylCro04UCu1QO0JvU6QKj2nB8yROr00jxBlpLUj';

/// Adresse de retour après une validation bancaire (Bancontact, 3-D Secure).
const stripeSchemaUrl = 'harambee';
