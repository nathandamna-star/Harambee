/// Adresse du site web d'un commerce, saisie librement par le commerçant
/// (« monmagasin.be », « www.monmagasin.be/boutique »…) et enregistrée sous une
/// forme complète (« https://monmagasin.be »). Renvoie null si l'adresse n'est
/// pas valable.
String? normaliserSiteWeb(String saisie) {
  var texte = saisie.trim();
  if (texte.isEmpty || texte.contains(RegExp(r'\s'))) return null;
  if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(texte)) {
    texte = 'https://$texte';
  }
  final uri = Uri.tryParse(texte);
  if (uri == null || !uri.hasAuthority) return null;
  final hote = uri.host.toLowerCase();
  // Un vrai nom de domaine : au moins un point et une extension de 2 lettres.
  if (!RegExp(r'^([a-z0-9-]+\.)+[a-z]{2,}$').hasMatch(hote)) return null;
  final propre = uri.replace(scheme: uri.scheme.toLowerCase(), host: hote);
  final resultat = propre.toString();
  if (resultat.length > 300) return null;
  // Pas de « / » final inutile sur une adresse simple.
  return propre.path == '/' && !propre.hasQuery && !propre.hasFragment
      ? resultat.substring(0, resultat.length - 1)
      : resultat;
}

/// Adresse lisible (sans « https:// » ni « www. ») pour l'affichage.
String siteWebLisible(String url) => url
    .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '')
    .replaceFirst(RegExp(r'^www\.'), '')
    .replaceFirst(RegExp(r'/$'), '');
