class Payload {
  String id = '';
  String sender = '';     // Display name
  String senderId;        // Required primary key
  String receiver = '';   // Display name
  String receiverId;      // Required primary key
  String message = '';
  String timestamp = '';
  bool broadcast = true;
  String type = 'Payload';

  Payload(
      this.id,
      this.sender,
      this.receiver,
      this.message,
      this.timestamp,
      {
        required this.senderId,
        required this.receiverId,
      });
}

class Ack {
  String id = '';
  String type = "Ack";
  String senderKey; // Required primary key of acknowledger

  Ack(this.id, {required this.senderKey});
}
