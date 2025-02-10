import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import '../classes/msg.dart';
import 'dart:convert';
import '../classes/payload.dart';
import '../encyption/rsa.dart';
import 'model.dart';
import 'message_db.dart';

/// This file has some utility functions for the
/// retrieval and saving of messages in the database.

Future<void> readAllUpdateConversation(BuildContext context) async {
  List<ConversationFromDB> conversations = await MessageDB.instance.readAllFromConversationsTable();
  for (var element in conversations) {
    if (!context.mounted) return;
    Provider.of<Global>(context, listen: false).sentToConversations(
      Msg(
          element.msg,
          element.type,
          element.timestamp,
          element.id,
          senderKey: element.senderKey,
          receiverKey: element.receiverKey
      ),
      element.converser,
      addToTable: false,
    );
  }
}


void readAllUpdatePublicKey() {
  List<PublicKeyFromDB> publicKey;
  MessageDB.instance.readAllFromPublicKeyTable().then((value) {
    publicKey = value;

    for (var element in publicKey) {
      String string = String.fromCharCodes(element.publicKey);
      Global.publicKeys[element.converser] =  parsePublicKeyFromPem(string);
    }
  });
}

void readAllUpdateCache() {
  List<MessageFromDB> messages ;
  MessageDB.instance.readAllFromMessagesTable().then((value) {
    messages = value;
    for (var element in messages) {
      if (element.type == 'Ack') {
        Global.cache[element.id] = convertToAck(element);
      } else {
        Global.cache[element.id] = convertToPayload(element);
      }
    }
  });
}

// Inserting message to the messages table in the database
void insertIntoMessageTable(dynamic msg) {
  if (msg.runtimeType == Payload) {
    MessageDB.instance.insertIntoMessagesTable(convertFromPayload(msg));
  } else {
    MessageDB.instance.insertIntoMessagesTable(convertFromAck(msg));
  }
}

// Inserting message to the conversation table in the database
void insertIntoConversationsTable(Msg msg, String converser) {
  MessageDB.instance.insertIntoConversationsTable(ConversationFromDB(
      msg.id,
      msg.msgtype,
      msg.message,
      msg.timestamp,
      msg.ack,
      converser,
      senderKey: msg.senderKey,
      receiverKey: msg.receiverKey
  ));
}

void deleteFromMessageTable(String id) {
  MessageDB.instance.deleteFromMessagesTable(id);
}

void updateMessageTable(String id, dynamic msg) {
  if (msg.runtimeType == Payload) {
    MessageDB.instance.updateMessageTable(convertFromPayload(msg));
  } else {
    MessageDB.instance.updateMessageTable(convertFromAck(msg));
  }
}

// Updated Payload conversion to include sender and receiver IDs
Payload convertToPayload(MessageFromDB message) {
  String id = message.id;
  String payload = message.msg;
  var json = jsonDecode(payload);
  return Payload(
      id,
      json['sender'] ?? '',
      json['receiver'] ?? '',
      json['message'] ?? '',
      json['timestamp'] ?? DateTime.now().toUtc().toString(),
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? ''
  );
}

MessageFromDB convertFromPayload(Payload msg) {
  String id = msg.id;
  String type = 'Payload';
  Map<String, dynamic> message = {
    "id": msg.id,
    "type": msg.type,
    "message": msg.message,
    "timestamp": msg.timestamp,
    "sender": msg.sender,
    "receiver": msg.receiver,
    "senderId": msg.senderId,
    "receiverId": msg.receiverId
  };
  return MessageFromDB(id, type, jsonEncode(message));
}

MessageFromDB convertFromAck(Ack msg) {
  String id = msg.id;
  String type = 'Ack';
  Map<String, String> message = {
    "id": msg.id,
    "type": msg.type,
    "senderKey": msg.senderKey
  };
  return MessageFromDB(id, type, jsonEncode(message));
}

Future<int> updateUserDisplayNameInDB(BuildContext context, String userId, String newDisplayName) async {
  try {
    // Update database
    final updateCount = await MessageDB.instance.updateUserDisplayName(userId, newDisplayName);

    // Update global state
    Provider.of<Global>(context, listen: false).handleProfileUpdate(userId, newDisplayName);

    return updateCount;
  } catch (e) {
    debugPrint('Error updating display name: $e');
    rethrow;
  }
}

// Add this function to load user names on app start
Future<void> loadUserNames(BuildContext context) async {
  final userNames = await MessageDB.instance.getAllUserNames();
  for (var userName in userNames) {
    Provider.of<Global>(context, listen: false)
        .updateUserProfile(userName.primaryKey, userName.displayName);
  }
}

Ack convertToAck(MessageFromDB msg) {
  var json = jsonDecode(msg.msg);
  return Ack(
      msg.id,
      senderKey: json['senderKey'] ?? '',
  );
}
