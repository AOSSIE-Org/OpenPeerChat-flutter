import 'dart:async';

import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'Payload.dart';

import 'Msg.dart';

class Global {
  static List<Device> devices = [];
  static List<Device> connectedDevices = [];
  static NearbyService? nearbyService;
  static StreamSubscription? subscription ;
  static StreamSubscription? receivedDataSubscription;
  static List<Msg> messages = [
    Msg("1", "test", "sent",'2'),
    Msg("2", "test2", "sent",'4')
  ];

  static Map<String, List<Map<String,Msg>>> conversations = Map();    //converser  mapped to conversation
  static String myName='';
  static Map<String,dynamic> cache=Map();
}
