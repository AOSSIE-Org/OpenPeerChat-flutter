import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/p2p/AdhocHousekeeping.dart';
import '../database/DatabaseHelper.dart';
import 'Msg.dart';

class Global extends ChangeNotifier {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  static NearbyService? nearbyService;
  static StreamSubscription? deviceSubscription;

  static StreamSubscription? receivedDataSubscription;
  static List<Msg> messages = [
    Msg("1", "test", "sent", '2'),
    Msg("2", "test2", "sent", '4')
  ];
  static Map<String, String> publicKeys = Map();
  Map<String, Map<String, Msg>> conversations = Map();
  static String myName = '';
  static Map<String, dynamic> cache = Map();
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();
  // Global({
  //   this.conversations = Map,
  // });
  void sentToConversations(Msg msg, String converser,
      {bool addToTable = true}) {
    if (conversations[converser] == null) {
      conversations[converser] = {};
    }
    conversations[converser]![msg.id] = msg;
    if (addToTable) {
      insertIntoConversationsTable(msg, converser);
    }
    notifyListeners();
    // First push the new message for one time when new message is sent
    broadcast(scaffoldKey.currentContext!);
  }

  void receivedToConversations(dynamic decodedMessage, BuildContext context) {
    if (conversations[decodedMessage['sender']] == null) {
      conversations[decodedMessage['sender']] = Map();
    }
    if (conversations[decodedMessage['sender']] != null &&
        !(conversations[decodedMessage['sender']]!
            .containsKey(decodedMessage['id']))) {
      conversations[decodedMessage['sender']]![decodedMessage["id"]] = Msg(
        decodedMessage['message'],
        "received",
        decodedMessage['Timestamp'],
        decodedMessage["id"],
      );
      insertIntoConversationsTable(
          Msg(decodedMessage['message'], "received",
              decodedMessage['Timestamp'], decodedMessage["id"]),
          decodedMessage['sender']);
    }

    notifyListeners();
  }

  void updateDevices(List<Device> devices) {
    this.devices = devices;
    notifyListeners();
  }

  void updateConnectedDevices(List<Device> devices) {
    this.connectedDevices = devices;
    notifyListeners();
  }
}
