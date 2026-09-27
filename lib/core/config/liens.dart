/// Adresses publiques de Harambee (fonctions HTTP du projet Firebase).
const _fonctions = 'https://europe-west1-harambee-75bab.cloudfunctions.net';

/// Page web d'un commerce : lien partagé et contenu des QR codes.
String lienCommerce(String commerceId) =>
    '$_fonctions/commerce?id=${Uri.encodeQueryComponent(commerceId)}';
