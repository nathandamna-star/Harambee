import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/commerce.dart';
import '../../../shared/models/conversation.dart';

/// Conversations entre un client et un commerce, et leurs messages.
class MessagerieRepository {
  MessagerieRepository({required this.firestore, required this.storage});

  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      firestore.collection('conversations');

  /// Conversations de [uid] (client ou pro), la plus récente d'abord.
  Stream<List<Conversation>> conversations(String uid) => _conversations
      .where('participants', arrayContains: uid)
      .snapshots()
      .map((s) {
        final liste = s.docs.map(Conversation.depuisFirestore).toList();
        final zero = DateTime.fromMillisecondsSinceEpoch(0);
        return liste..sort(
          (a, b) => (b.updatedAt ?? zero).compareTo(a.updatedAt ?? zero),
        );
      });

  Stream<Conversation?> conversation(String id) => _conversations
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Conversation.depuisFirestore(d) : null);

  /// Ouvre (ou retrouve) la conversation du client avec un commerce.
  Future<String> ouvrir({
    required Commerce commerce,
    required String clientId,
    required String clientNom,
  }) async {
    final id = Conversation.identifiant(commerce.id, clientId);
    final ref = _conversations.doc(id);
    if (!(await ref.get()).exists) {
      await ref.set(
        Conversation(
          commerceId: commerce.id,
          commerceNom: commerce.nom,
          clientId: clientId,
          clientNom: clientNom,
          proId: commerce.proprietaire,
        ).pourCreation(),
      );
    }
    return id;
  }

  /// Derniers messages, du plus ancien au plus récent.
  Stream<List<Message>> messages(String conversationId, {int limite = 100}) =>
      _conversations
          .doc(conversationId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limite)
          .snapshots()
          .map(
            (s) =>
                s.docs.map(Message.depuisFirestore).toList().reversed.toList(),
          );

  /// Envoie un message (texte et/ou photo) et met à jour l'aperçu de la
  /// conversation et le compteur de non-lus de l'interlocuteur.
  Future<void> envoyer(
    Conversation conversation, {
    required String auteur,
    String texte = '',
    Uint8List? photo,
    String apercuPhoto = '📷',
  }) async {
    final texteNet = texte.trim();
    if (texteNet.isEmpty && photo == null) return;
    String? photoUrl;
    if (photo != null) {
      final ref = storage.ref(
        'conversations/${conversation.id}/${const Uuid().v4()}.jpg',
      );
      await ref.putData(photo, SettableMetadata(contentType: 'image/jpeg'));
      photoUrl = await ref.getDownloadURL();
    }
    final refConv = _conversations.doc(conversation.id);
    await refConv
        .collection('messages')
        .add(
          Message(
            id: '',
            auteur: auteur,
            texte: texteNet,
            photoUrl: photoUrl,
          ).pourCreation(),
        );
    final destinataireEstPro = auteur == conversation.clientId;
    await refConv.update({
      'dernierMessage': texteNet.isEmpty ? apercuPhoto : _apercu(texteNet),
      'updatedAt': FieldValue.serverTimestamp(),
      destinataireEstPro ? 'nonLusPro' : 'nonLusClient': FieldValue.increment(
        1,
      ),
    });
  }

  /// Remet à zéro les non-lus de [uid] quand il ouvre la conversation.
  Future<void> marquerLue(Conversation conversation, String uid) async {
    if (conversation.nonLusPour(uid) == 0) return;
    await _conversations.doc(conversation.id).update({
      uid == conversation.clientId ? 'nonLusClient' : 'nonLusPro': 0,
    });
  }

  /// Bloque ou débloque la conversation pour [uid].
  Future<void> definirBlocage(
    String conversationId,
    String uid,
    bool bloquer,
  ) => _conversations.doc(conversationId).update({
    'bloquePar': bloquer
        ? FieldValue.arrayUnion([uid])
        : FieldValue.arrayRemove([uid]),
  });

  static String _apercu(String texte) =>
      texte.length <= 100 ? texte : '${texte.substring(0, 100)}…';
}
