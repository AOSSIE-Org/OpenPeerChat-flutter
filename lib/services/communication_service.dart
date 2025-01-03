import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:web_socket_channel/web_socket_channel.dart';

class CommunicationService {
  static final WebSocketChannel _channel =
      WebSocketChannel.connect(Uri.parse('ws://your-websocket-server-url'));

  /// Broadcasts a profile update to all connected peers
  static void broadcastProfileUpdate(String userId, String newName) {
    final message = {
      'type': 'profile_update',
      'userId': userId,
      'newName': newName,
    };

    _channel.sink.add(jsonEncode(message));
  }

  /// Listens for incoming messages
  static void listen(void Function(Map<String, dynamic>) onMessage) {
    _channel.stream.listen((data) {
      final decodedData = jsonDecode(data);
      onMessage(decodedData);
    });
  }

  /// Closes the WebSocket connection
  static void closeConnection() {
    _channel.sink.close();
  }
}
