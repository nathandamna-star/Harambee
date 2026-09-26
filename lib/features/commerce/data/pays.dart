import '../../../shared/models/enums.dart';

/// Pays proposés à l'inscription d'un commerce.
/// Le continent et la devise par défaut en découlent.
class Pays {
  const Pays(this.code, this.continent, this.devise, this.fr, this.en, this.pt);

  /// Code ISO 3166-1 alpha-2, stocké dans `commerces.pays`.
  final String code;
  final Continent continent;
  final Devise devise;
  final String fr;
  final String en;
  final String pt;

  String nom(String langue) => switch (langue) {
    'en' => en,
    'pt' => pt,
    _ => fr,
  };

  static Pays? depuisCode(String? code) {
    for (final p in tous) {
      if (p.code == code) return p;
    }
    return null;
  }

  static const tous = <Pays>[
    // Europe
    Pays('FR', Continent.europe, Devise.EUR, 'France', 'France', 'França'),
    Pays('BE', Continent.europe, Devise.EUR, 'Belgique', 'Belgium', 'Bélgica'),
    Pays('CH', Continent.europe, Devise.EUR, 'Suisse', 'Switzerland', 'Suíça'),
    Pays(
      'LU',
      Continent.europe,
      Devise.EUR,
      'Luxembourg',
      'Luxembourg',
      'Luxemburgo',
    ),
    Pays(
      'DE',
      Continent.europe,
      Devise.EUR,
      'Allemagne',
      'Germany',
      'Alemanha',
    ),
    Pays('IT', Continent.europe, Devise.EUR, 'Italie', 'Italy', 'Itália'),
    Pays('ES', Continent.europe, Devise.EUR, 'Espagne', 'Spain', 'Espanha'),
    Pays(
      'PT',
      Continent.europe,
      Devise.EUR,
      'Portugal',
      'Portugal',
      'Portugal',
    ),
    Pays(
      'NL',
      Continent.europe,
      Devise.EUR,
      'Pays-Bas',
      'Netherlands',
      'Países Baixos',
    ),
    Pays(
      'GB',
      Continent.europe,
      Devise.EUR,
      'Royaume-Uni',
      'United Kingdom',
      'Reino Unido',
    ),
    Pays('IE', Continent.europe, Devise.EUR, 'Irlande', 'Ireland', 'Irlanda'),
    // Afrique
    Pays(
      'CI',
      Continent.afrique,
      Devise.XOF,
      'Côte d\'Ivoire',
      'Côte d\'Ivoire',
      'Costa do Marfim',
    ),
    Pays('SN', Continent.afrique, Devise.XOF, 'Sénégal', 'Senegal', 'Senegal'),
    Pays('ML', Continent.afrique, Devise.XOF, 'Mali', 'Mali', 'Mali'),
    Pays(
      'BF',
      Continent.afrique,
      Devise.XOF,
      'Burkina Faso',
      'Burkina Faso',
      'Burkina Faso',
    ),
    Pays('BJ', Continent.afrique, Devise.XOF, 'Bénin', 'Benin', 'Benim'),
    Pays('TG', Continent.afrique, Devise.XOF, 'Togo', 'Togo', 'Togo'),
    Pays('NE', Continent.afrique, Devise.XOF, 'Niger', 'Niger', 'Níger'),
    Pays(
      'GW',
      Continent.afrique,
      Devise.XOF,
      'Guinée-Bissau',
      'Guinea-Bissau',
      'Guiné-Bissau',
    ),
    Pays(
      'CM',
      Continent.afrique,
      Devise.XAF,
      'Cameroun',
      'Cameroon',
      'Camarões',
    ),
    Pays('GA', Continent.afrique, Devise.XAF, 'Gabon', 'Gabon', 'Gabão'),
    Pays('CG', Continent.afrique, Devise.XAF, 'Congo', 'Congo', 'Congo'),
    Pays('TD', Continent.afrique, Devise.XAF, 'Tchad', 'Chad', 'Chade'),
    Pays(
      'CF',
      Continent.afrique,
      Devise.XAF,
      'Centrafrique',
      'Central African Republic',
      'República Centro-Africana',
    ),
    Pays(
      'GQ',
      Continent.afrique,
      Devise.XAF,
      'Guinée équatoriale',
      'Equatorial Guinea',
      'Guiné Equatorial',
    ),
    Pays(
      'CD',
      Continent.afrique,
      Devise.CDF,
      'RD Congo',
      'DR Congo',
      'RD Congo',
    ),
    Pays('NG', Continent.afrique, Devise.NGN, 'Nigeria', 'Nigeria', 'Nigéria'),
    Pays('GH', Continent.afrique, Devise.GHS, 'Ghana', 'Ghana', 'Gana'),
    Pays('GN', Continent.afrique, Devise.EUR, 'Guinée', 'Guinea', 'Guiné'),
    Pays('AO', Continent.afrique, Devise.USD, 'Angola', 'Angola', 'Angola'),
    Pays(
      'MZ',
      Continent.afrique,
      Devise.USD,
      'Mozambique',
      'Mozambique',
      'Moçambique',
    ),
    Pays(
      'CV',
      Continent.afrique,
      Devise.EUR,
      'Cap-Vert',
      'Cape Verde',
      'Cabo Verde',
    ),
    Pays('KE', Continent.afrique, Devise.USD, 'Kenya', 'Kenya', 'Quênia'),
    Pays('RW', Continent.afrique, Devise.USD, 'Rwanda', 'Rwanda', 'Ruanda'),
    Pays(
      'MG',
      Continent.afrique,
      Devise.EUR,
      'Madagascar',
      'Madagascar',
      'Madagáscar',
    ),
    // Amérique
    Pays(
      'US',
      Continent.amerique,
      Devise.USD,
      'États-Unis',
      'United States',
      'Estados Unidos',
    ),
    Pays('CA', Continent.amerique, Devise.CAD, 'Canada', 'Canada', 'Canadá'),
    Pays('BR', Continent.amerique, Devise.USD, 'Brésil', 'Brazil', 'Brasil'),
    Pays('HT', Continent.amerique, Devise.USD, 'Haïti', 'Haiti', 'Haiti'),
  ];
}
