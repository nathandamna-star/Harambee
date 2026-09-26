import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harambee/features/auth/data/auth_repository.dart';
import 'package:harambee/features/auth/domain/role.dart';

import '../../helpers.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late AuthRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = AuthRepository(
      auth: MockFirebaseAuth(
        mockUser: MockUser(uid: 'u1', email: 'awa@exemple.com'),
      ),
      firestore: firestore,
      google: FausseConnexionGoogle(),
    );
  });

  test('un profil existant garde son rôle à la reconnexion', () async {
    await firestore.collection('users').doc('u1').set({'role': 'pro'});
    await repo.connexionGoogle(roleSouhaite: Role.client, langue: 'fr');
    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.data()!['role'], 'pro');
  });

  test('le rôle admin n\'est jamais écrit par l\'app', () async {
    await repo.connexionGoogle(roleSouhaite: Role.admin, langue: 'pt');
    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.data()!['role'], 'client');
    expect(doc.data()!['langue'], 'pt');
  });

  test('« admin » dans le profil est lu comme client', () {
    expect(Role.depuisTexte('admin'), Role.client);
    expect(Role.depuisTexte('pro'), Role.pro);
    expect(Role.depuisTexte(null), Role.client);
  });
}
