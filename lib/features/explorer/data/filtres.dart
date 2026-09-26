import '../../../shared/models/enums.dart';

/// Filtres de l'écran Explorer.
class FiltresExplorer {
  const FiltresExplorer({
    this.recherche = '',
    this.continent,
    this.categorie,
    this.africain = false,
    this.chretien = false,
    this.ouvertMaintenant = false,
  });

  final String recherche;
  final Continent? continent;
  final Categorie? categorie;
  final bool africain;
  final bool chretien;
  final bool ouvertMaintenant;

  /// Nombre de filtres actifs (hors recherche texte).
  int get nbActifs => [
    continent != null,
    categorie != null,
    africain,
    chretien,
    ouvertMaintenant,
  ].where((a) => a).length;

  FiltresExplorer copyWith({
    String? recherche,
    Continent? Function()? continent,
    Categorie? Function()? categorie,
    bool? africain,
    bool? chretien,
    bool? ouvertMaintenant,
  }) => FiltresExplorer(
    recherche: recherche ?? this.recherche,
    continent: continent != null ? continent() : this.continent,
    categorie: categorie != null ? categorie() : this.categorie,
    africain: africain ?? this.africain,
    chretien: chretien ?? this.chretien,
    ouvertMaintenant: ouvertMaintenant ?? this.ouvertMaintenant,
  );

  @override
  bool operator ==(Object other) =>
      other is FiltresExplorer &&
      other.recherche == recherche &&
      other.continent == continent &&
      other.categorie == categorie &&
      other.africain == africain &&
      other.chretien == chretien &&
      other.ouvertMaintenant == ouvertMaintenant;

  @override
  int get hashCode => Object.hash(
    recherche,
    continent,
    categorie,
    africain,
    chretien,
    ouvertMaintenant,
  );
}
