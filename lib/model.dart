
final String tableName = 'messages';

class MessageTableFields {
  static final List<String> values = [id, type, msg];
  static final String type = 'type';
  static final String msg = 'msg';
  static final String id = '_id';
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
