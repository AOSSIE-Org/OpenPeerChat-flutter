import 'package:flutter/services.dart';

/// Models for different use cases and constants
///
const String messagesTableName = 'messages';
const String conversationsTableName = 'conversations';
const String publicKeyTableName = 'publicKey';
const String userNamesTableName = 'user_names';

class UserNameFields {
  static final List<String> values = [primaryKey, displayName, lastUpdated];
  static const String primaryKey = 'primary_key';
  static const String displayName = 'display_name';
  static const String lastUpdated = 'last_updated';
}

class UserNameFromDB {
  final String primaryKey;
  final String displayName;
  final String lastUpdated;

  UserNameFromDB(this.primaryKey, this.displayName, this.lastUpdated);

  Map<String, Object> toJson() => {
    UserNameFields.primaryKey: primaryKey,
    UserNameFields.displayName: displayName,
    UserNameFields.lastUpdated: lastUpdated,
  };

  static UserNameFromDB fromJson(Map<String, Object?> json) => UserNameFromDB(
    json[UserNameFields.primaryKey] as String,
    json[UserNameFields.displayName] as String,
    json[UserNameFields.lastUpdated] as String,
  );
}


class MessageTableFields {
  static final List<String> values = [id, type, msg];
  static const String type = 'type';
  static const String msg = 'msg';
  static const String id = '_id';
}

// Update ConversationTableFields to include sender and receiver keys
class ConversationTableFields {
  static final List<String> values = [
    id, type, msg, converser, timestamp, ack, senderKey, receiverKey
  ];
  static const String type = 'type';
  static const String msg = 'msg';
  static const String id = '_id';
  static const String converser = 'converser';
  static const String timestamp = 'timestamp';
  static const String ack = 'ack';
  static const String senderKey = 'senderKey';
  static const String receiverKey = 'receiverKey';
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

// Update ConversationFromDB class with sender and receiver keys
class ConversationFromDB {
  final String type;
  final String msg;
  final String id;
  final String converser;
  final String timestamp;
  final String ack;
  final String senderKey;
  final String receiverKey;

  ConversationFromDB(
      this.id,
      this.type,
      this.msg,
      this.timestamp,
      this.ack,
      this.converser,
      {
        required this.senderKey,
        required this.receiverKey,
      }
      );

  Map<String, Object?> toJson() => {
    ConversationTableFields.id: id,
    ConversationTableFields.type: type,
    ConversationTableFields.msg: msg,
    ConversationTableFields.converser: converser,
    ConversationTableFields.ack: ack,
    ConversationTableFields.timestamp: timestamp,
    ConversationTableFields.senderKey: senderKey,
    ConversationTableFields.receiverKey: receiverKey,
  };

  static ConversationFromDB fromJson(Map<String, Object?> json) =>
      ConversationFromDB(
        json[ConversationTableFields.id].toString(),
        json[ConversationTableFields.type].toString(),
        json[ConversationTableFields.msg].toString(),
        json[ConversationTableFields.timestamp].toString(),
        json[ConversationTableFields.ack].toString(),
        json[ConversationTableFields.converser].toString(),
        senderKey: json[ConversationTableFields.senderKey].toString(),
        receiverKey: json[ConversationTableFields.receiverKey].toString(),
      );
}
