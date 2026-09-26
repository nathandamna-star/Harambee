import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'notifications_service.dart';

final notificationsServiceProvider = Provider<NotificationsService>(
  (ref) => NotificationsFirebase(
    messaging: FirebaseMessaging.instance,
    firestore: ref.watch(firestoreProvider),
  ),
);
