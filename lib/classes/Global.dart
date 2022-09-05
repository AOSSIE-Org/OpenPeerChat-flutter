import 'dart:async';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import 'Msg.dart';

class Global {
  static List<Device> devices = [];
  static List<Device> connectedDevices = [];
  static NearbyService? nearbyService;
  static StreamSubscription? deviceSubscription;

  static StreamSubscription? receivedDataSubscription;
  static List<Msg> messages = [
    Msg("1", "test", "sent", '2'),
    Msg("2", "test2", "sent", '4')
  ];
  static Map<String, String> publicKeys = Map();
  static Map<String, Map<String, Msg>> conversations =
      {}; //converser  mapped to conversation

  static String myName = '';
  static Map<String, dynamic> cache = Map();
}
