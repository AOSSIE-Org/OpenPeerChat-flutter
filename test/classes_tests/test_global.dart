import 'package:test/test.dart';
import '../classes/Global.dart';

void main() {
  group('Global', () {
    test('Initial device list should be empty', () {
      expect(Global.devices, isEmpty);
    });

    test('Initial connected devices list should be empty', () {
      expect(Global.connectedDevices, isEmpty);
    });

    test('Initial nearbyService should be null', () {
      expect(Global.nearbyService, isNull);
    });

    test('Initial subscription should be null', () {
      expect(Global.subscription, isNull);
    });

    test('Initial receivedDataSubscription should be null', () {
      expect(Global.receivedDataSubscription, isNull);
    });

    test('Initial messages list should not be empty', () {
      expect(Global.messages, isNotEmpty);
    });

    test('Initial publicKeys map should be empty', () {
      expect(Global.publicKeys, isEmpty);
    });

    test('Initial conversations map should be empty', () {
      expect(Global.conversations, isEmpty);
    });

    test('Initial myName should be an empty string', () {
      expect(Global.myName, isEmpty);
    });

    test('Initial cache map should be empty', () {
      expect(Global.cache, isEmpty);
    });
  });
}
