/// Horaires stockés par jour : `{"lundi": ["09:00-19:00"]}`.
/// Une plage qui finit avant de commencer (« 18:00-02:00 ») passe minuit.
library;

const joursSemaine = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

/// Vrai si le commerce est ouvert à [maintenant] (heure du téléphone).
bool estOuvert(Map<String, List<String>> horaires, DateTime maintenant) {
  final minutes = maintenant.hour * 60 + maintenant.minute;
  final aujourdhui = joursSemaine[maintenant.weekday - 1];
  final hier = joursSemaine[(maintenant.weekday + 5) % 7];

  for (final plage in horaires[aujourdhui] ?? const <String>[]) {
    final (debut, fin) = _lire(plage) ?? (-1, -1);
    if (debut < 0) continue;
    if (fin > debut ? (minutes >= debut && minutes < fin) : minutes >= debut) {
      return true;
    }
  }
  // Plage de la veille qui déborde après minuit.
  for (final plage in horaires[hier] ?? const <String>[]) {
    final (debut, fin) = _lire(plage) ?? (-1, -1);
    if (debut >= 0 && fin < debut && minutes < fin) return true;
  }
  return false;
}

(int, int)? _lire(String plage) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$').firstMatch(plage);
  if (m == null) return null;
  int v(int i) => int.parse(m.group(i)!);
  return (v(1) * 60 + v(2), v(3) * 60 + v(4));
}
