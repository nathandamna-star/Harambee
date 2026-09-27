import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_options.dart';
import 'data/auth_repository.dart';
import 'data/connexion_google.dart';
import 'domain/role.dart';
import 'domain/utilisateur.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final connexionGoogleProvider = Provider<ConnexionGoogle>(
  (ref) => ConnexionGoogleNative(
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? googleIosClientId
        : null,
    serverClientId: googleServerClientId,
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    google: ref.watch(connexionGoogleProvider),
  ),
);

/// Utilisateur Firebase connecté (null si personne n'est connecté).
/// Suit aussi le rafraîchissement du jeton, pour voir un nouveau custom claim.
final utilisateurFirebaseProvider = StreamProvider<User?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  yield auth.currentUser;
  yield* auth.idTokenChanges();
});

/// Vrai si le jeton porte le custom claim `admin: true`.
final estAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(utilisateurFirebaseProvider).value;
  if (user == null) return false;
  final jeton = await user.getIdTokenResult();
  return jeton.claims?['admin'] == true;
});

/// Profil Firestore de l'utilisateur connecté.
final profilProvider = StreamProvider<Utilisateur?>((ref) {
  final user = ref.watch(utilisateurFirebaseProvider).value;
  if (user == null) return Stream.value(null);
  return ref
      .watch(firestoreProvider)
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? Utilisateur.depuisFirestore(doc) : null);
});

/// Rôle courant, ou null si personne n'est connecté.
final roleProvider = Provider<Role?>((ref) {
  final user = ref.watch(utilisateurFirebaseProvider).value;
  if (user == null) return null;
  if (ref.watch(estAdminProvider).value ?? false) return Role.admin;
  return ref.watch(profilProvider).value?.role ?? Role.client;
});

/// Choix fait sur l'écran de bienvenue avant de se connecter.
final roleSouhaiteProvider = NotifierProvider<RoleSouhaite, Role>(
  RoleSouhaite.new,
);

class RoleSouhaite extends Notifier<Role> {
  @override
  Role build() => Role.client;

  void choisir(Role role) => state = role;
}
