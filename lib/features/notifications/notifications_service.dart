import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Notifications push : enregistrement du téléphone et ouverture de la
/// conversation quand on touche une notification.
abstract interface class NotificationsService {
  /// Demande l'autorisation et enregistre le jeton du téléphone pour [uid].
  Future<void> activer(String uid);

  /// Oublie le jeton de ce téléphone (à la déconnexion).
  Future<void> desactiver(String uid);

  /// Données des notifications touchées (`conversationId` ou `commandeId`).
  Stream<Map<String, dynamic>> get notificationsTouchees;
}

class NotificationsFirebase implements NotificationsService {
  NotificationsFirebase({required this.messaging, required this.firestore});

  final FirebaseMessaging messaging;
  final FirebaseFirestore firestore;
  StreamSubscription<String>? _renouvellement;

  DocumentReference<Map<String, dynamic>> _profil(String uid) =>
      firestore.collection('users').doc(uid);

  @override
  Future<void> activer(String uid) async {
    try {
      final autorisation = await messaging.requestPermission();
      if (autorisation.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
      final jeton = await messaging.getToken();
      if (jeton != null) await _enregistrer(uid, jeton);
      await _renouvellement?.cancel();
      _renouvellement = messaging.onTokenRefresh.listen(
        (j) => _enregistrer(uid, j),
      );
    } catch (_) {
      // Sur iPhone, sans configuration Apple (APNs), aucun jeton n'est
      // disponible : l'app fonctionne normalement, sans notifications.
    }
  }

  Future<void> _enregistrer(String uid, String jeton) => _profil(uid).update({
    'jetonsNotif': FieldValue.arrayUnion([jeton]),
  });

  @override
  Future<void> desactiver(String uid) async {
    await _renouvellement?.cancel();
    _renouvellement = null;
    try {
      final jeton = await messaging.getToken();
      if (jeton != null) {
        await _profil(uid).update({
          'jetonsNotif': FieldValue.arrayRemove([jeton]),
        });
      }
      await messaging.deleteToken();
    } catch (_) {
      // Pas de jeton sur ce téléphone : rien à oublier.
    }
  }

  @override
  Stream<Map<String, dynamic>> get notificationsTouchees async* {
    final initiale = await messaging.getInitialMessage();
    if (initiale != null) yield initiale.data;
    yield* FirebaseMessaging.onMessageOpenedApp.map((m) => m.data);
  }
}
