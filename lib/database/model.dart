
final String messagesTableName = 'messages';
final String conversationsTableName = 'conversations';
class MessageTableFields {
  static final List<String> values = [id, type, msg];
  static final String type = 'type';
  static final String msg = 'msg';
  static final String id = '_id';
}
class ConversationTableFields {
  static final List<String> values = [id, type, msg,converser,timestamp,ack];
  static final String type = 'type';
  static final String msg = 'msg';
  static final String id = '_id';
  static final String converser='converser';
  static final String timestamp='timestamp';
  static final String ack='ack';
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
  ConversationFromDB(this.id, this.type, this.msg,this.timestamp,this.ack,this.converser);

  Map<String, Object?> toJson() => {
    ConversationTableFields.id: id,
    ConversationTableFields.type: type,
    ConversationTableFields.msg: msg,
    ConversationTableFields.converser:converser,
    ConversationTableFields.ack:ack,
    ConversationTableFields.timestamp:timestamp

  };

  static ConversationFromDB fromJson(Map<String, Object?> json) =>  ConversationFromDB(
      json[ConversationTableFields.id].toString(),
      json[ConversationTableFields.type].toString(),
      json[ConversationTableFields.msg].toString(),
      json[ConversationTableFields.timestamp].toString(),
      json[ConversationTableFields.ack].toString(),
      json[ConversationTableFields.converser].toString()
  );


}
