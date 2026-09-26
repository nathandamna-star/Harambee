import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/conversation.dart';
import '../auth/auth_providers.dart';
import '../commerce/commerce_providers.dart';
import 'data/messagerie_repository.dart';

final messagerieRepositoryProvider = Provider<MessagerieRepository>(
  (ref) => MessagerieRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
  ),
);

final mesConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(messagerieRepositoryProvider).conversations(uid);
});

/// Total des messages non lus (pastille de l'onglet Messages).
final totalNonLusProvider = Provider<int>((ref) {
  final uid = ref.watch(utilisateurFirebaseProvider).value?.uid;
  if (uid == null) return 0;
  final liste = ref.watch(mesConversationsProvider).value ?? const [];
  return liste.fold(0, (total, c) => total + c.nonLusPour(uid));
});

final conversationProvider = StreamProvider.family<Conversation?, String>(
  (ref, id) => ref.watch(messagerieRepositoryProvider).conversation(id),
);

final messagesProvider = StreamProvider.family<List<Message>, String>(
  (ref, id) => ref.watch(messagerieRepositoryProvider).messages(id),
);
