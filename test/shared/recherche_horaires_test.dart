import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/shared/models/horaires.dart';
import 'package:harambee/shared/models/recherche.dart';

void main() {
  group('recherche', () {
    test('mots normalisés : minuscules, sans accents', () {
      expect(motsNormalises('Maquis Chez Awa — Côte d\'Ivoire'), [
        'maquis',
        'chez',
        'awa',
        'cote',
        'd',
        'ivoire',
      ]);
    });

    test('mots-clés : débuts de mots de 2 lettres et plus', () {
      final cles = motsClesRecherche(['Chez Mama', 'Lyon']);
      expect(
        cles,
        containsAll(['ch', 'che', 'chez', 'ma', 'mam', 'mama', 'ly', 'lyon']),
      );
      expect(cles, isNot(contains('c')));
      expect(cles, isNot(contains('ama')));
    });

    test('correspondance : chaque mot recherché commence un mot', () {
      expect(correspondRecherche('mam lyo', ['Chez Mama', 'Lyon']), isTrue);
      expect(
        correspondRecherche('Élégance', ['Salon elegance', 'Paris']),
        isTrue,
      );
      expect(correspondRecherche('mam paris', ['Chez Mama', 'Lyon']), isFalse);
      expect(correspondRecherche('', ['X']), isTrue);
    });
  });

  group('ouvert maintenant', () {
    final horaires = {
      'lundi': ['09:00-19:00'],
      'vendredi': ['18:00-02:00'],
    };
    // 2026-09-28 est un lundi.
    DateTime le(int jour, int h, [int m = 0]) => DateTime(2026, 9, jour, h, m);

    test('pendant et hors des horaires', () {
      expect(estOuvert(horaires, le(28, 10)), isTrue);
      expect(estOuvert(horaires, le(28, 8, 59)), isFalse);
      expect(estOuvert(horaires, le(28, 19)), isFalse);
      expect(estOuvert(horaires, le(29, 10)), isFalse); // mardi : fermé
    });

    test('vendredi soir jusqu\'à 2 h du matin', () {
      final vendredi = DateTime(2026, 10, 2, 23);
      final samediNuit = DateTime(2026, 10, 3, 1, 30);
      final samediMatin = DateTime(2026, 10, 3, 3);
      expect(estOuvert(horaires, vendredi), isTrue);
      expect(estOuvert(horaires, samediNuit), isTrue);
      expect(estOuvert(horaires, samediMatin), isFalse);
    });
  });
}
