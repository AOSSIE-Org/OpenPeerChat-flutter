import 'dart:async';

import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import 'Msg.dart';
import 'Conversation.dart';

class Global {
  static List<Device> devices = [];
  static List<Device> connectedDevices = [];
  static NearbyService? nearbyService;
  static StreamSubscription? subscription ;
  static StreamSubscription? receivedDataSubscription;
  static List<Msg> messages = [
    Msg("1", "test", "sent"),
    Msg("2", "test2", "sent")
  ];
  static Map<String, Conversation> conversations = Map();
  static String myName='';
}
