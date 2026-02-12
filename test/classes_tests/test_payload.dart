import 'package:test/test.dart';
import '../classes/Payload.dart'; 

void main() {
  group('Payload and Ack Tests', () {
    test('Payload Initialization', () {
      final payload = Payload("1", "sender", "receiver", "message", "timestamp");

      expect(payload.id, "1");
      expect(payload.sender, "sender");
      expect(payload.receiver, "receiver");
      expect(payload.message, "message");
      expect(payload.timestamp, "timestamp");
      expect(payload.broadcast, true);
      expect(payload.type, "Payload");
    });

    test('Ack Initialization', () {
      final ack = Ack("1");

      expect(ack.id, "1");
      expect(ack.type, "Ack");
    });
  });
}
