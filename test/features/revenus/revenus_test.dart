import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/features/revenus/data/revenus.dart';
import 'package:harambee/shared/models/commande.dart';
import 'package:harambee/shared/models/enums.dart';

Commande commande(
  String id, {
  required DateTime le,
  MethodePaiement methode = MethodePaiement.especes,
  StatutPaiement paiement = StatutPaiement.enAttente,
  StatutCommande statut = StatutCommande.retiree,
  num total = 17.69,
  num fraisService = 0.69,
  num commission = 1.19,
  num fraisPaiement = 0,
  num? fraisPaiementReel,
  String pays = 'BE',
  String commerceId = 'mama',
}) => Commande(
  id: id,
  commerceId: commerceId,
  commerceNom: commerceId == 'mama' ? 'Chez Mama' : 'Chez Kofi',
  clientId: 'c',
  clientNom: 'Awa',
  proId: 'p',
  lignes: const [],
  sousTotal: 17,
  fraisLivraison: 0,
  fraisService: fraisService,
  commissionPlateforme: commission,
  fraisPaiement: fraisPaiement,
  fraisPaiementReel: fraisPaiementReel,
  total: total,
  devise: Devise.EUR,
  mode: ModeCommande.emporter,
  telephoneClient: '',
  methodePaiement: methode,
  statutPaiement: paiement,
  statut: statut,
  historique: const [],
  createdAt: le,
  pays: pays,
);

void main() {
  final sept = DateTime(2026, 9, 10);
  final oct = DateTime(2026, 10, 2);
  final commandes = [
    commande('especes1', le: sept),
    commande(
      'carte1',
      le: sept,
      methode: MethodePaiement.carte,
      paiement: StatutPaiement.paye,
      fraisPaiement: 0.52,
      fraisPaiementReel: 0.50,
    ),
    // Non comptées : carte non payée, refusée, en cours.
    commande('carteNonPayee', le: sept, methode: MethodePaiement.carte),
    commande('refusee', le: sept, statut: StatutCommande.refusee),
    commande('enCours', le: sept, statut: StatutCommande.prete),
    commande('octobre', le: oct, pays: 'FR', commerceId: 'kofi'),
  ];

  test('seules les commandes terminées (et payées si carte) comptent', () {
    expect(commandes.where(compteDansRevenus).map((c) => c.id), [
      'especes1',
      'carte1',
      'octobre',
    ]);
  });

  test('récapitulatif mensuel du commerçant', () {
    final recaps = recapsMensuels(commandes);
    final r = recaps[((annee: 2026, mois: 9), Devise.EUR)]!;
    expect(r.nb, 2);
    expect(r.ventes, 35.38);
    expect(r.commission, 2.38);
    expect(r.fraisService, 1.38);
    expect(r.fraisPaiement, 0.52);
    // 17,69 − 0,69 − 1,19 = 15,81 (espèces) ; 15,81 − 0,52 = 15,29 (carte)
    expect(r.net, 31.10);
    expect(r.verseCarte, 15.29);
    expect(r.ventesEspeces, 17.69);
    // Dû sur les espèces : frais de service + commission.
    expect(r.duEspeces, 1.88);
    expect(recaps.length, 2);
  });

  test('revenus de la plateforme par mois, et par pays', () {
    final r = revenusParMois(commandes)[((annee: 2026, mois: 9), Devise.EUR)]!;
    expect(r.commissions, 2.38);
    expect(r.fraisService, 1.38);
    expect(r.fraisPaiementRetenus, 0.52);
    expect(r.fraisPaiementReels, 0.50);
    expect(r.total, 3.78);
    expect(r.aFacturerEspeces, 1.88);
    final belgique = revenusParMois(commandes, pays: 'BE');
    expect(belgique.keys.map((k) => k.$1.mois), [9]);
  });

  test('dû par commerce sur les espèces d\'un mois', () {
    expect(duParCommerce(commandes, (annee: 2026, mois: 9)), {
      ('mama', 'Chez Mama', Devise.EUR): 1.88,
    });
    expect(duParCommerce(commandes, (annee: 2026, mois: 10)), {
      ('kofi', 'Chez Kofi', Devise.EUR): 1.88,
    });
  });

  test('export CSV : en-têtes, une ligne par commande, champs protégés', () {
    final r = recapsMensuels(commandes)[((annee: 2026, mois: 9), Devise.EUR)]!;
    final csv = csvRecap(r, ['Date', 'N°', 'Client; nom']);
    final lignes = csv.trim().split('\n');
    expect(lignes, hasLength(3));
    expect(lignes.first, 'Date;N°;"Client; nom"');
    expect(
      lignes[1],
      startsWith(
        '2026-09-10;#ESPECE;Awa;especes;17.69;0;0.69;1.19;0;15.81;EUR',
      ),
    );
  });
}
