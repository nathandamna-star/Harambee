import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/shared/models/avis.dart';
import 'package:harambee/shared/models/commerce.dart';
import 'package:harambee/shared/models/conversation.dart';
import 'package:harambee/shared/models/enums.dart';
import 'package:harambee/shared/models/produit.dart';
import 'package:harambee/shared/models/signalement.dart';

void main() {
  late FakeFirebaseFirestore db;
  setUp(() => db = FakeFirebaseFirestore());

  test(
    'commerce : création imposée « en vérification », relecture fidèle',
    () async {
      const commerce = Commerce(
        id: '',
        nom: 'Chez Mama',
        categorie: Categorie.restaurant,
        proprietaire: 'pro1',
        continent: Continent.afrique,
        ville: 'Abidjan',
        pays: 'CI',
        geo: GeoPoint(5.35, -4.02),
        horaires: {
          'lundi': ['09:00-14:00'],
        },
        labelAfricain: true,
        statut: StatutCommerce.publie, // ignoré à la création
      );
      final ref = await db.collection('commerces').add(commerce.pourCreation());
      final relu = Commerce.depuisFirestore(await ref.get());

      expect(relu.nom, 'Chez Mama');
      expect(relu.categorie, Categorie.restaurant);
      expect(relu.continent, Continent.afrique);
      expect(relu.statut, StatutCommerce.enVerification);
      expect(relu.estPublie, isFalse);
      expect(relu.labelAfricain, isTrue);
      expect(relu.geo, const GeoPoint(5.35, -4.02));
      expect(relu.horaires['lundi'], ['09:00-14:00']);
      expect(relu.noteMoyenne, 0);
      expect(relu.nbAvis, 0);
    },
  );

  test('commerce : la modification ne touche pas aux champs réservés', () {
    const commerce = Commerce(
      id: 'c1',
      nom: 'X',
      categorie: Categorie.magasin,
      proprietaire: 'pro1',
      continent: Continent.europe,
    );
    final donnees = commerce.pourModification();
    for (final champ in [
      'statut',
      'labelAfricain',
      'labelChretien',
      'proprietaire',
      'noteMoyenne',
      'nbAvis',
    ]) {
      expect(donnees.containsKey(champ), isFalse, reason: champ);
    }
  });

  test('statut et valeurs inconnues : repli sûr', () {
    expect(StatutCommerce.depuis('publie'), StatutCommerce.publie);
    expect(StatutCommerce.depuis('???'), StatutCommerce.enVerification);
    expect(enumDepuis(Devise.values, 'XOF', Devise.EUR), Devise.XOF);
    expect(enumDepuis(Devise.values, 'BTC', Devise.EUR), Devise.EUR);
  });

  test('produit : aller-retour avec devise', () async {
    const produit = Produit(
      id: '',
      nom: 'Attiéké poisson',
      prix: 3500,
      devise: Devise.XOF,
      enRupture: true,
    );
    final ref = await db.collection('produits').add(produit.versFirestore());
    final relu = Produit.depuisFirestore(await ref.get());
    expect(relu.prix, 3500);
    expect(relu.devise, Devise.XOF);
    expect(relu.enRupture, isTrue);
  });

  test('avis : identifiant = auteur, note bornée', () async {
    const avis = Avis(auteur: 'client1', note: 4, texte: 'Bon accueil');
    await db.doc('commerces/c1/avis/${avis.auteur}').set(avis.pourCreation());
    final relu = Avis.depuisFirestore(
      await db.doc('commerces/c1/avis/client1').get(),
    );
    expect(relu.auteur, 'client1');
    expect(relu.note, 4);
  });

  test('conversation : identifiant et participants', () {
    const conv = Conversation(
      commerceId: 'c1',
      commerceNom: 'Chez Mama',
      clientId: 'client1',
      proId: 'pro1',
    );
    expect(conv.id, 'c1__client1');
    expect(conv.pourCreation()['participants'], ['client1', 'pro1']);
  });

  test('signalement : toujours créé « non traité »', () {
    const s = Signalement(
      auteur: 'client1',
      cible: CibleSignalement.avis,
      cibleId: 'a1',
      motif: 'Insultant',
      traite: true,
    );
    expect(s.pourCreation()['traite'], isFalse);
    expect(s.pourCreation()['cible'], 'avis');
  });
}
