import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

enum ModeCommande { livraison, emporter }

enum MethodePaiement { carte, especes }

enum StatutPaiement {
  enAttente('en_attente'),
  paye('paye'),
  rembourse('rembourse'),
  echoue('echoue');

  const StatutPaiement(this.valeur);
  final String valeur;

  static StatutPaiement depuis(String? v) =>
      values.firstWhere((s) => s.valeur == v, orElse: () => enAttente);
}

enum StatutCommande {
  nouvelle('nouvelle'),
  acceptee('acceptee'),
  enPreparation('en_preparation'),
  prete('prete'),
  enLivraison('en_livraison'),
  livree('livree'),
  retiree('retiree'),
  refusee('refusee'),
  annulee('annulee');

  const StatutCommande(this.valeur);
  final String valeur;

  static StatutCommande depuis(String? v) =>
      values.firstWhere((s) => s.valeur == v, orElse: () => nouvelle);

  bool get estTerminee =>
      const {livree, retiree, refusee, annulee}.contains(this);

  /// Étape suivante proposée au commerçant.
  StatutCommande? suivant(ModeCommande mode) => switch (this) {
    nouvelle => acceptee,
    acceptee => enPreparation,
    enPreparation => prete,
    prete => mode == ModeCommande.livraison ? enLivraison : retiree,
    enLivraison => livree,
    _ => null,
  };
}

/// Réglages de commande d'un commerce (`commerces/{id}.commande`).
class ReglagesCommande {
  const ReglagesCommande({
    this.active = false,
    this.modes = const {ModeCommande.emporter},
    this.minimumCommande = 0,
    this.minimumLivraison = 0,
    this.fraisLivraison = 0,
    this.livraisonGratuiteDes,
    this.rayonLivraisonKm = 5,
    this.delaiPreparationMin = 30,
    this.especesAcceptees = true,
    this.devise = Devise.EUR,
  });

  final bool active;
  final Set<ModeCommande> modes;
  final num minimumCommande;
  final num minimumLivraison;
  final num fraisLivraison;
  final num? livraisonGratuiteDes;
  final num rayonLivraisonKm;
  final int delaiPreparationMin;
  final bool especesAcceptees;
  final Devise devise;

  static ReglagesCommande? depuis(Object? donnees) {
    if (donnees is! Map) return null;
    final d = donnees.cast<String, dynamic>();
    return ReglagesCommande(
      active: d['active'] as bool? ?? false,
      modes: {
        for (final m in (d['modes'] as List? ?? const []))
          if (ModeCommande.values.asNameMap()[m] != null)
            ModeCommande.values.asNameMap()[m]!,
      },
      minimumCommande: d['minimumCommande'] as num? ?? 0,
      minimumLivraison: d['minimumLivraison'] as num? ?? 0,
      fraisLivraison: d['fraisLivraison'] as num? ?? 0,
      livraisonGratuiteDes: d['livraisonGratuiteDes'] as num?,
      rayonLivraisonKm: d['rayonLivraisonKm'] as num? ?? 5,
      delaiPreparationMin: (d['delaiPreparationMin'] as num? ?? 30).toInt(),
      especesAcceptees: d['especesAcceptees'] as bool? ?? true,
      devise: enumDepuis(Devise.values, d['devise'] as String?, Devise.EUR),
    );
  }

  Map<String, dynamic> versFirestore() => {
    'active': active,
    'modes': [for (final m in modes) m.name],
    'minimumCommande': minimumCommande,
    'minimumLivraison': minimumLivraison,
    'fraisLivraison': fraisLivraison,
    'livraisonGratuiteDes': livraisonGratuiteDes,
    'rayonLivraisonKm': rayonLivraisonKm,
    'delaiPreparationMin': delaiPreparationMin,
    'especesAcceptees': especesAcceptees,
    'devise': devise.name,
  };
}

class LigneCommande {
  const LigneCommande({
    required this.produitId,
    required this.nom,
    required this.prixUnitaire,
    required this.quantite,
  });

  final String produitId;
  final String nom;
  final num prixUnitaire;
  final int quantite;

  num get total => prixUnitaire * quantite;
}

class EtapeCommande {
  const EtapeCommande(this.statut, this.date);
  final StatutCommande statut;
  final DateTime? date;
}

/// Commande : `commandes/{id}`. Créée uniquement par la Cloud Function
/// `creerCommande`, qui fixe tous les montants.
class Commande {
  const Commande({
    required this.id,
    required this.commerceId,
    required this.commerceNom,
    required this.clientId,
    required this.clientNom,
    required this.proId,
    required this.lignes,
    required this.sousTotal,
    required this.fraisLivraison,
    required this.fraisService,
    required this.commissionPlateforme,
    required this.fraisPaiement,
    required this.total,
    required this.devise,
    required this.mode,
    required this.telephoneClient,
    required this.methodePaiement,
    required this.statutPaiement,
    required this.statut,
    required this.historique,
    this.adresseTexte,
    this.adresseGeo,
    this.instructions,
    this.motifRefus,
    this.createdAt,
  });

  final String id;
  final String commerceId;
  final String commerceNom;
  final String clientId;
  final String clientNom;
  final String proId;
  final List<LigneCommande> lignes;
  final num sousTotal;
  final num fraisLivraison;
  final num fraisService;
  final num commissionPlateforme;
  final num fraisPaiement;
  final num total;
  final Devise devise;
  final ModeCommande mode;
  final String telephoneClient;
  final MethodePaiement methodePaiement;
  final StatutPaiement statutPaiement;
  final StatutCommande statut;
  final List<EtapeCommande> historique;
  final String? adresseTexte;
  final GeoPoint? adresseGeo;
  final String? instructions;
  final String? motifRefus;
  final DateTime? createdAt;

  /// Numéro court affiché (« #A1B2C3 »).
  String get numero =>
      '#${id.length >= 6 ? id.substring(0, 6) : id}'.toUpperCase();

  /// Montant reçu par le commerce : tout ce que paie le client, moins les frais
  /// de service (plateforme), la commission et les frais de paiement.
  num get montantNet =>
      total - fraisService - commissionPlateforme - fraisPaiement;

  factory Commande.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    final adresse = d['adresseLivraison'] as Map<String, dynamic>?;
    final paiement = d['paiement'] as Map<String, dynamic>? ?? const {};
    return Commande(
      id: doc.id,
      commerceId: d['commerceId'] as String? ?? '',
      commerceNom: d['commerceNom'] as String? ?? '',
      clientId: d['clientId'] as String? ?? '',
      clientNom: d['clientNom'] as String? ?? '',
      proId: d['proId'] as String? ?? '',
      lignes: [
        for (final l in (d['lignes'] as List? ?? const []))
          LigneCommande(
            produitId: l['produitId'] as String? ?? '',
            nom: l['nom'] as String? ?? '',
            prixUnitaire: l['prixUnitaire'] as num? ?? 0,
            quantite: (l['quantite'] as num? ?? 1).toInt(),
          ),
      ],
      sousTotal: d['sousTotal'] as num? ?? 0,
      fraisLivraison: d['fraisLivraison'] as num? ?? 0,
      fraisService: d['fraisService'] as num? ?? 0,
      commissionPlateforme: d['commissionPlateforme'] as num? ?? 0,
      fraisPaiement: d['fraisPaiement'] as num? ?? 0,
      total: d['total'] as num? ?? 0,
      devise: enumDepuis(Devise.values, d['devise'] as String?, Devise.EUR),
      mode: enumDepuis(
        ModeCommande.values,
        d['mode'] as String?,
        ModeCommande.emporter,
      ),
      telephoneClient: d['telephoneClient'] as String? ?? '',
      methodePaiement: enumDepuis(
        MethodePaiement.values,
        paiement['methode'] as String?,
        MethodePaiement.especes,
      ),
      statutPaiement: StatutPaiement.depuis(paiement['statut'] as String?),
      statut: StatutCommande.depuis(d['statut'] as String?),
      historique: [
        for (final e in (d['historique'] as List? ?? const []))
          EtapeCommande(
            StatutCommande.depuis(e['statut'] as String?),
            (e['date'] as Timestamp?)?.toDate(),
          ),
      ],
      adresseTexte: adresse?['texte'] as String?,
      adresseGeo: adresse?['geo'] as GeoPoint?,
      instructions: adresse?['instructions'] as String?,
      motifRefus: d['motifRefus'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
