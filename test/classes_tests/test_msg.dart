import 'package:test/test.dart';
import '../classes/Msg.dart';

void main() {
  group('Msg', () {
    test('Initialization', () {
      final msg = Msg("Test Message", "sent", "2023-01-01", "1");

      expect(msg.message, "Test Message");
      expect(msg.msgtype, "sent");
      expect(msg.timestamp, "2023-01-01");
      expect(msg.id, "1");
      expect(msg.ack, "false");
    });

    test('Acknowledgment Default Value', () {
      final msg = Msg("Test Message", "sent", "2023-01-01", "1");

      expect(msg.ack, "false");
    });
  });
}
