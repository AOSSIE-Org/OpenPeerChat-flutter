import 'package:flutter_nearby_connections_example/classes/Global.dart';
import 'package:flutter_nearby_connections_example/classes/Msg.dart';
import 'dart:convert';
import '../classes/Payload.dart';

import 'model.dart';
import 'MessageDB.dart';
void readAllUpdateConversation(){
  List<ConversationFromDB> conversations = [ConversationFromDB("1", "2","3", "5", "6", "7")];
  MessageDB.instance.readAllFromConversationsTable().then((value) {
    conversations= value;
    conversations.forEach((element) {
      Global.conversations[element.converser]!.add({element.id:Msg(element.msg,element.type,element.timestamp,element.id)});
      // Global.conversations[element.converser]![element.id]=Msg(element.msg,element.type,element.timestamp,element.id);
    });
  });
}
void readAllUpdateCache() {
  List<MessageFromDB> messages = [MessageFromDB("1", "2", "3")];
  MessageDB.instance.readAllFromMessagesTable().then((value) {
    messages = value;
    print("10 tablevalues");
    value.forEach((element) {print("_id ${element.id} type ${element.type} msg: ${element.msg}\n");});
    print(value);
    messages.forEach((element) {
      print("line 16 dbhelper");
      if (element.type == 'Ack')
        Global.cache[element.id] = convertToAck(element);
      else
        Global.cache[element.id] = convertToPayload(element);
    });
    print("reloaded cache #22 "+Global.cache.toString());
  });

}

void insertIntoMessageTable(dynamic msg) {
  if (msg.runtimeType == Payload)
    MessageDB.instance.insertIntoMessagesTable(convertFromPayload(msg));
  else
    MessageDB.instance.insertIntoMessagesTable(convertFromAck(msg));
}
void insertIntoConversationsTable(Msg msg,String converser) {
    MessageDB.instance.insertIntoConversationsTable(ConversationFromDB(msg.id,msg.msgtype,msg.message,msg.timestamp,msg.ack,converser));
}

void deleteFromMessageTable(String id) {
  MessageDB.instance.deleteFromMessagesTable(id);
}

void updateMessageTable(String id, dynamic msg) {
  if (msg.runtimeType == Payload)
    MessageDB.instance.updateMessageTable(convertFromPayload(msg));
  else
    MessageDB.instance.updateMessageTable(convertFromAck(msg));
}

Ack convertToAck(MessageFromDB msg) {
  String id = msg.id;
  return Ack(id);
}

Payload convertToPayload(MessageFromDB message) {
  String id = message.id;
  String payload = message.msg;
  print("#61: ${payload}");
  var json = jsonDecode(payload);
  print("#63"+json.toString());
  print("#62 ${json['id']}| ${json['sender']}");
  return Payload(
      id, json['sender'], json['receiver'], json['message'], json['timestamp']);
}

MessageFromDB convertFromPayload(Payload msg) {
  String id = msg.id;
  String type = 'Payload';
  Map<String, String> message = {
    "id": msg.id,
    "type": msg.type,
    "message": msg.message,
    "timestamp": msg.timestamp,
    "sender": msg.sender,
    "receiver": msg.receiver
  };
  print("#80"+jsonEncode(message));
  return MessageFromDB(id, type, jsonEncode(message));
}

MessageFromDB convertFromAck(Ack msg) {
  String id = msg.id;
  String type = 'Ack';
  Map<String, String> message = {
    "id": msg.id,
    "type": msg.type,
  };
  return MessageFromDB(id, type,jsonEncode(message));
}
