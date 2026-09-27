import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/features/commerce/data/commerce_repository.dart';
import 'package:harambee/features/commerce/data/photos_service.dart';
import 'package:harambee/shared/models/commerce.dart';
import 'package:harambee/shared/models/enums.dart';
import 'package:harambee/shared/models/produit.dart';

import '../../helpers.dart';

void main() {
  late FakeFirebaseFirestore db;
  late CommerceRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = CommerceRepository(
      firestore: db,
      photos: PhotosService(MockFirebaseStorage()),
    );
  });

  const paris = Commerce(
    id: '',
    nom: 'Chez Mama',
    categorie: Categorie.restaurant,
    proprietaire: 'pro1',
    continent: Continent.europe,
    pays: 'FR',
    ville: 'Paris',
    geo: GeoPoint(48.8566, 2.3522),
    statut: StatutCommerce.publie, // doit être ignoré
  );

  test(
    'création : en vérification, geohash calculé, photos envoyées',
    () async {
      final id = await repo.creer(paris, [
        PhotoFiche.nouvelle(imageTest),
        PhotoFiche.nouvelle(imageTest),
      ]);
      final c = Commerce.depuisFirestore(await db.doc('commerces/$id').get());
      expect(c.statut, StatutCommerce.enVerification);
      expect(c.proprietaire, 'pro1');
      // Geohash de Paris : vérifie aussi l'ordre latitude/longitude.
      expect(c.geohash, startsWith('u09tv'));
      expect(c.photos, hasLength(2));
    },
  );

  test(
    'modification : photo retirée, nouvelle ajoutée, statut inchangé',
    () async {
      final id = await repo.creer(paris, [PhotoFiche.nouvelle(imageTest)]);
      final existant = Commerce.depuisFirestore(
        await db.doc('commerces/$id').get(),
      );
      await repo.modifier(existant, [PhotoFiche.nouvelle(imageTest)]);
      final c = Commerce.depuisFirestore(await db.doc('commerces/$id').get());
      expect(c.photos, hasLength(1));
      expect(c.photos.single, isNot(existant.photos.single));
      expect(c.statut, StatutCommerce.enVerification);
    },
  );

  test('au plus 12 photos par fiche', () async {
    final id = await repo.creer(paris, [
      for (var i = 0; i < 15; i++) PhotoFiche.nouvelle(imageTest),
    ]);
    final c = Commerce.depuisFirestore(await db.doc('commerces/$id').get());
    expect(c.photos, hasLength(12));
  });

  test('commerces du pro : uniquement les siens', () async {
    await repo.creer(paris, []);
    await db.collection('commerces').add({
      'nom': 'Autre',
      'proprietaire': 'pro2',
    });
    final liste = await repo.commercesDuPro('pro1').first;
    expect(liste.map((c) => c.nom), ['Chez Mama']);
  });

  group('produits', () {
    Produit produit(String nom) =>
        Produit(id: '', nom: nom, prix: 5, devise: Devise.EUR);

    test(
      'ajout à la suite, réordonnancement, masquer, rupture, suppression',
      () async {
        await repo.enregistrerProduit('c1', produit('A'));
        await repo.enregistrerProduit(
          'c1',
          produit('B'),
          nouvellePhoto: imageTest,
        );
        await repo.enregistrerProduit('c1', produit('C'));
        var liste = await repo.produits('c1').first;
        expect(liste.map((p) => p.nom), ['A', 'B', 'C']);
        expect(liste[1].photoUrl, isNotNull);

        await repo.reordonner('c1', [liste[2].id, liste[0].id, liste[1].id]);
        liste = await repo.produits('c1').first;
        expect(liste.map((p) => p.nom), ['C', 'A', 'B']);

        await repo.definirPublie('c1', liste[0].id, false);
        await repo.definirRupture('c1', liste[1].id, true);
        await repo.supprimerProduit('c1', liste[2]);
        liste = await repo.produits('c1').first;
        expect(liste.map((p) => p.nom), ['C', 'A']);
        expect(liste[0].publie, isFalse);
        expect(liste[1].enRupture, isTrue);
      },
    );

    test('modification d\'un produit existant', () async {
      await repo.enregistrerProduit('c1', produit('A'));
      final p = (await repo.produits('c1').first).single;
      await repo.enregistrerProduit(
        'c1',
        Produit(id: p.id, nom: 'A modifié', prix: 7.5, devise: Devise.XOF),
      );
      final relu = (await repo.produits('c1').first).single;
      expect(relu.nom, 'A modifié');
      expect(relu.prix, 7.5);
      expect(relu.devise, Devise.XOF);
    });
  });
}
