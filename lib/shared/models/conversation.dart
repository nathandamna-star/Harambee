import 'package:cloud_firestore/cloud_firestore.dart';

/// Conversation client ↔ commerce : `conversations/{commerceId__clientUid}`.
class Conversation {
  const Conversation({
    required this.commerceId,
    required this.commerceNom,
    required this.clientId,
    required this.proId,
    this.clientNom = '',
    this.dernierMessage = '',
    this.updatedAt,
    this.nonLusClient = 0,
    this.nonLusPro = 0,
  });

  final String commerceId;
  final String commerceNom;
  final String clientId;
  final String clientNom;
  final String proId;
  final String dernierMessage;
  final DateTime? updatedAt;
  final int nonLusClient;
  final int nonLusPro;

  static String identifiant(String commerceId, String clientId) =>
      '${commerceId}__$clientId';

  String get id => identifiant(commerceId, clientId);
  List<String> get participants => [clientId, proId];

  /// Nombre de messages non lus pour [uid].
  int nonLusPour(String uid) => uid == clientId ? nonLusClient : nonLusPro;

  /// Nom affiché pour l'interlocuteur de [uid].
  String interlocuteur(String uid) => uid == clientId ? commerceNom : clientNom;

  factory Conversation.depuisFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data() ?? const {};
    return Conversation(
      commerceId: d['commerceId'] as String? ?? '',
      commerceNom: d['commerceNom'] as String? ?? '',
      clientId: d['clientId'] as String? ?? '',
      clientNom: d['clientNom'] as String? ?? '',
      proId: d['proId'] as String? ?? '',
      dernierMessage: d['dernierMessage'] as String? ?? '',
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
      nonLusClient: (d['nonLusClient'] as num? ?? 0).toInt(),
      nonLusPro: (d['nonLusPro'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> pourCreation() => {
    'commerceId': commerceId,
    'commerceNom': commerceNom,
    'clientId': clientId,
    'clientNom': clientNom,
    'proId': proId,
    'participants': participants,
    'dernierMessage': dernierMessage,
    'nonLusClient': 0,
    'nonLusPro': 0,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// Message : `conversations/{id}/messages/{messageId}`.
class Message {
  const Message({
    required this.id,
    required this.auteur,
    required this.texte,
    this.photoUrl,
    this.createdAt,
  });

  final String id;
  final String auteur;
  final String texte;
  final String? photoUrl;
  final DateTime? createdAt;

  factory Message.depuisFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Message(
      id: doc.id,
      auteur: d['auteur'] as String? ?? '',
      texte: d['texte'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// `createdAt` est fixé par le serveur (exigé par les règles).
  Map<String, dynamic> pourCreation() => {
    'auteur': auteur,
    'texte': texte,
    if (photoUrl != null) 'photoUrl': photoUrl,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
