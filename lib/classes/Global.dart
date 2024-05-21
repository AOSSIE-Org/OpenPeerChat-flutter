import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:pointycastle/export.dart';
import '../database/DatabaseHelper.dart';
import '../p2p/AdhocHousekeeping.dart';
import 'Msg.dart';


class Global extends ChangeNotifier {
  static RSAPrivateKey? myPrivateKey;
  static RSAPublicKey? myPublicKey;
  static NearbyService? nearbyService;
  static StreamSubscription? deviceSubscription;
  static StreamSubscription? receivedDataSubscription;

  List<Device> devices = [];
  List<Device> connectedDevices = [];
  static List<Msg> messages = [];
  static Map<String, RSAPublicKey> publicKeys = {};
  Map<String, Map<String, Msg>> conversations = {};
  static String myName = '';
  static Map<String, dynamic> cache = {};
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  void sentToConversations(Msg msg, String converser, {bool addToTable = true}) {
    conversations.putIfAbsent(converser, () => {});
    conversations[converser]![msg.id] = msg;
    if (addToTable) {
      insertIntoConversationsTable(msg, converser);
    }
    notifyListeners();
    broadcast(scaffoldKey.currentContext!);
  }

  void receivedToConversations(dynamic decodedMessage, BuildContext context) {
    var sender = decodedMessage['sender'];
    conversations.putIfAbsent(sender, () => {});
    if (!conversations[sender]!.containsKey(decodedMessage['id'])) {
      var msg = Msg(decodedMessage['message'], "received", decodedMessage['Timestamp'], decodedMessage['id']);
      conversations[sender]![decodedMessage["id"]] = msg;
      insertIntoConversationsTable(msg, sender);
      notifyListeners();
    }
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
