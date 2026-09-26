/// Recherche texte sans service externe : chaque commerce enregistre
/// `motsCles`, la liste des débuts de mots (2 à 15 lettres) de son nom et de sa
/// ville, en minuscules et sans accents. Une recherche « mam » trouve alors
/// « Chez Mama » via une requête `array-contains`.
library;

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ã': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'õ': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ñ': 'n',
  'œ': 'oe',
  'æ': 'ae',
};

/// Minuscules, sans accents, découpé en mots.
List<String> motsNormalises(String texte) {
  final buffer = StringBuffer();
  for (final r in texte.toLowerCase().runes) {
    final c = String.fromCharCode(r);
    buffer.write(_accents[c] ?? c);
  }
  return buffer
      .toString()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((m) => m.isNotEmpty)
      .toList();
}

/// Débuts de mots indexés pour la recherche.
List<String> motsClesRecherche(List<String> textes) {
  final cles = <String>{};
  for (final mot in textes.expand(motsNormalises)) {
    for (var n = 2; n <= mot.length && n <= 15; n++) {
      cles.add(mot.substring(0, n));
    }
  }
  return cles.toList()..sort();
}

/// Vrai si chaque mot de la recherche commence un mot de [textes].
bool correspondRecherche(String recherche, List<String> textes) {
  final mots = textes.expand(motsNormalises).toList();
  return motsNormalises(recherche)
      .every((r) => mots.any((m) => m.startsWith(r)));
}
