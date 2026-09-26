import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/erreur_auth.dart';
import '../domain/role.dart';
import 'connexion_google.dart';

/// Connexion, inscription et création du profil `users/{uid}`.
class AuthRepository {
  AuthRepository({
    required this.auth,
    required this.firestore,
    required this.google,
  });

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final ConnexionGoogle google;

  Future<void> connexionEmail({
    required String email,
    required String motDePasse,
  }) => _executer(() async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
  });

  Future<void> inscriptionEmail({
    required String nom,
    required String email,
    required String motDePasse,
    required Role roleSouhaite,
    required String langue,
  }) => _executer(() async {
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: motDePasse,
    );
    await cred.user!.updateDisplayName(nom.trim());
    await _assurerProfil(cred.user!, roleSouhaite, langue, nom: nom.trim());
  });

  Future<void> connexionGoogle({
    required Role roleSouhaite,
    required String langue,
  }) => _executer(() async {
    final idToken = await google.obtenirIdToken();
    final cred = await auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    await _assurerProfil(cred.user!, roleSouhaite, langue);
  });

  Future<void> connexionApple({
    required Role roleSouhaite,
    required String langue,
  }) => _executer(() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final cred = await auth.signInWithProvider(provider);
    await _assurerProfil(cred.user!, roleSouhaite, langue);
  });

  Future<void> motDePasseOublie(String email) =>
      _executer(() => auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> deconnexion() async {
    await google.deconnecter().catchError((_) {});
    await auth.signOut();
  }

  /// Crée `users/{uid}` à la première connexion. Un profil existant n'est
  /// jamais modifié ici (son rôle reste celui choisi à l'inscription).
  Future<void> _assurerProfil(
    User user,
    Role roleSouhaite,
    String langue, {
    String? nom,
  }) async {
    final ref = firestore.collection('users').doc(user.uid);
    if ((await ref.get()).exists) return;
    await ref.set({
      'nom': nom ?? user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      // Jamais « admin » : ce rôle passe par un custom claim.
      'role': roleSouhaite == Role.pro ? 'pro' : 'client',
      'langue': langue,
      'ville': null,
      'pays': null,
      'favoris': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _executer(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw ExceptionAuth(ErreurAuth.depuisCode(e.code));
    } on FirebaseException catch (e) {
      throw ExceptionAuth(
        e.code == 'unavailable' ? ErreurAuth.reseau : ErreurAuth.inconnue,
      );
    }
  }
}
