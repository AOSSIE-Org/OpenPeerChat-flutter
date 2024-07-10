
class Msg {
  String message;
  String msgtype; //sent or received
  String timestamp;
  String ack = 'false';
  String id;
  Msg(this.message, this.msgtype, this.timestamp, this.id);
}
