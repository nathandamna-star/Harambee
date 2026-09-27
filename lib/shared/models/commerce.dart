import 'package:cloud_firestore/cloud_firestore.dart';

import 'commande.dart';
import 'enums.dart';
import 'recherche.dart';

/// Fiche d'un commerce : `commerces/{commerceId}`.
class Commerce {
  const Commerce({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.proprietaire,
    required this.continent,
    this.description = '',
    this.photos = const [],
    this.adresse = '',
    this.geo,
    this.geohash,
    this.pays = '',
    this.ville = '',
    this.horaires = const {},
    this.telephone,
    this.siteWeb,
    this.devise = Devise.EUR,
    this.commande,
    this.paiementCarteActif = false,
    this.labelAfricain = false,
    this.labelChretien = false,
    this.charteSigneeLe,
    this.statut = StatutCommerce.enVerification,
    this.motifRefus,
    this.noteMoyenne = 0,
    this.nbAvis = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String nom;
  final Categorie categorie;
  final String description;
  final List<String> photos;
  final String adresse;
  final GeoPoint? geo;
  final String? geohash;
  final String pays;
  final String ville;
  final Continent continent;

  /// Horaires par jour, ex. `{"lundi": ["09:00-12:00", "14:00-19:00"]}`.
  final Map<String, List<String>> horaires;
  final String? telephone;

  /// Site web du commerce (adresse complète, voir `normaliserSiteWeb`).
  final String? siteWeb;

  /// Devise par défaut des prix du catalogue.
  final Devise devise;

  /// Réglages de la commande en ligne (null : jamais configurée).
  final ReglagesCommande? commande;

  /// Paiement par carte possible (compte Stripe relié ; fixé par le serveur).
  final bool paiementCarteActif;
  final bool labelAfricain;
  final bool labelChretien;
  final DateTime? charteSigneeLe;
  final StatutCommerce statut;
  final String? motifRefus;
  final String proprietaire;
  final double noteMoyenne;
  final int nbAvis;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get estPublie => statut == StatutCommerce.publie;

  /// Les clients peuvent commander en ligne.
  bool get commandeOuverte =>
      estPublie && (commande?.active ?? false) && commande!.modes.isNotEmpty;

  Commerce copyWith({
    String? id,
    List<String>? photos,
    GeoPoint? geo,
    String? geohash,
  }) => Commerce(
    id: id ?? this.id,
    nom: nom,
    categorie: categorie,
    proprietaire: proprietaire,
    continent: continent,
    description: description,
    photos: photos ?? this.photos,
    adresse: adresse,
    geo: geo ?? this.geo,
    geohash: geohash ?? this.geohash,
    pays: pays,
    ville: ville,
    horaires: horaires,
    telephone: telephone,
    siteWeb: siteWeb,
    devise: devise,
    commande: commande,
    paiementCarteActif: paiementCarteActif,
    labelAfricain: labelAfricain,
    labelChretien: labelChretien,
    charteSigneeLe: charteSigneeLe,
    statut: statut,
    motifRefus: motifRefus,
    noteMoyenne: noteMoyenne,
    nbAvis: nbAvis,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory Commerce.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Commerce(
      id: doc.id,
      nom: d['nom'] as String? ?? '',
      categorie: enumDepuis(
        Categorie.values,
        d['categorie'] as String?,
        Categorie.service,
      ),
      description: d['description'] as String? ?? '',
      photos: List<String>.from(d['photos'] as List? ?? const []),
      adresse: d['adresse'] as String? ?? '',
      geo: d['geo'] as GeoPoint?,
      geohash: d['geohash'] as String?,
      pays: d['pays'] as String? ?? '',
      ville: d['ville'] as String? ?? '',
      continent: enumDepuis(
        Continent.values,
        d['continent'] as String?,
        Continent.europe,
      ),
      horaires: {
        for (final e in (d['horaires'] as Map? ?? const {}).entries)
          e.key as String: List<String>.from(e.value as List? ?? const []),
      },
      telephone: d['telephone'] as String?,
      siteWeb: d['siteWeb'] as String?,
      devise: enumDepuis(Devise.values, d['devise'] as String?, Devise.EUR),
      commande: ReglagesCommande.depuis(d['commande']),
      paiementCarteActif: d['paiementCarteActif'] as bool? ?? false,
      labelAfricain: d['labelAfricain'] as bool? ?? false,
      labelChretien: d['labelChretien'] as bool? ?? false,
      charteSigneeLe: (d['charteSigneeLe'] as Timestamp?)?.toDate(),
      statut: StatutCommerce.depuis(d['statut'] as String?),
      motifRefus: d['motifRefus'] as String?,
      proprietaire: d['proprietaire'] as String? ?? '',
      noteMoyenne: (d['noteMoyenne'] as num? ?? 0).toDouble(),
      nbAvis: (d['nbAvis'] as num? ?? 0).toInt(),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Données pour la création par le pro. Statut, note et nombre d'avis
  /// sont imposés : les règles de sécurité refusent toute autre valeur.
  Map<String, dynamic> pourCreation() => {
    ..._champsModifiables(),
    'labelAfricain': labelAfricain,
    'labelChretien': labelChretien,
    'statut': StatutCommerce.enVerification.valeur,
    'proprietaire': proprietaire,
    'noteMoyenne': 0,
    'nbAvis': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// Données modifiables ensuite par le propriétaire.
  Map<String, dynamic> pourModification() => {
    ..._champsModifiables(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> _champsModifiables() => {
    'nom': nom,
    'motsCles': motsClesRecherche([nom, ville]),
    'categorie': categorie.name,
    'description': description,
    'photos': photos,
    'adresse': adresse,
    'geo': geo,
    'geohash': geohash,
    'pays': pays,
    'ville': ville,
    'continent': continent.name,
    'horaires': horaires,
    'telephone': telephone,
    'siteWeb': siteWeb,
    'devise': devise.name,
    'charteSigneeLe': charteSigneeLe == null
        ? null
        : Timestamp.fromDate(charteSigneeLe!),
  };
}
