class Msg {
  String message;
  String msgtype;
  String timestamp;
  String ack = 'false';
  String id;
  String senderKey;    // Primary key of sender
  String receiverKey;  // Primary key of receiver
  String senderName;   // Display name of sender
  String receiverName; // Display name of receiver

  Msg(
      this.message,
      this.msgtype,
      this.timestamp,
      this.id, {
        this.senderKey = '',
        this.receiverKey = '',
        this.senderName = '',
        this.receiverName = '',
      });
}
