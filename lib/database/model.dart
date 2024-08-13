import 'package:flutter/services.dart';

/// Models for different use cases and constants
///
const String messagesTableName = 'messages';
const String conversationsTableName = 'conversations';
const String publicKeyTableName = 'publicKey';

class MessageTableFields {
  static final List<String> values = [id, type, msg];
  static const String type = 'type';
  static const String msg = 'msg';
  static const String id = '_id';
}

class ConversationTableFields {
  static final List<String> values = [id, type, msg, converser, timestamp, ack];
  static const String type = 'type';
  static const String msg = 'msg';
  static const String id = '_id';
  static const String converser = 'converser';
  static const String timestamp = 'timestamp';
  static const String ack = 'ack';
}

class PublicKeyFields {
  static const String converser = 'converser';
  static const String publicKey = 'publicKey';
}

class PublicKeyFromDB {
  final String converser;
  final Uint8List publicKey;

  PublicKeyFromDB(this.converser, this.publicKey);

  Map<String, Object> toJson() => {
    PublicKeyFields.converser: converser,
    PublicKeyFields.publicKey: publicKey,
  };

  static PublicKeyFromDB fromJson(Map<String, Object?> json) => PublicKeyFromDB(
    json[PublicKeyFields.converser] as String,
    json[PublicKeyFields.publicKey] as Uint8List,
  );
}

class MessageFromDB {
  final String type;
  final String msg;
  final String id;

  MessageFromDB(this.id, this.type, this.msg);

  Map<String, Object?> toJson() => {
        MessageTableFields.id: id,
        MessageTableFields.type: type,
        MessageTableFields.msg: msg
      };

  static MessageFromDB fromJson(Map<String, Object?> json) => MessageFromDB(
      json[MessageTableFields.id].toString(),
      json[MessageTableFields.type].toString(),
      json[MessageTableFields.msg].toString());
}

class ConversationFromDB {
  final String type;
  final String msg;
  final String id;
  final String converser;
  final String timestamp;
  final String ack;

  ConversationFromDB(
      this.id, this.type, this.msg, this.timestamp, this.ack, this.converser);

  Map<String, Object?> toJson() => {
        ConversationTableFields.id: id,
        ConversationTableFields.type: type,
        ConversationTableFields.msg: msg,
        ConversationTableFields.converser: converser,
        ConversationTableFields.ack: ack,
        ConversationTableFields.timestamp: timestamp
      };

  static ConversationFromDB fromJson(Map<String, Object?> json) =>
      ConversationFromDB(
          json[ConversationTableFields.id].toString(),
          json[ConversationTableFields.type].toString(),
          json[ConversationTableFields.msg].toString(),
          json[ConversationTableFields.timestamp].toString(),
          json[ConversationTableFields.ack].toString(),
          json[ConversationTableFields.converser].toString());
}
