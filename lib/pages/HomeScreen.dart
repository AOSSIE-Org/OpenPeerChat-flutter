import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/pages/ChatListScreen.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import '../classes/Global.dart';
import '../p2p/AdhocHousekeeping.dart';
import 'DeviceListScreen.dart';

import '../classes/Payload.dart';
import '../database/DatabaseHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isInit = false;

  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    init();
    refreshMessages();
  }

  void init() async {
    initiateNearbyService();
    checkDevices();
    broadcastLastMessageID(context);
    Global.receivedDataSubscription =
        Global.nearbyService!.dataReceivedSubscription(callback: (data) {
      var decodedMessage = jsonDecode(data['message']);
      showToast(
        jsonEncode(data),
        context: context,
        axis: Axis.horizontal,
        alignment: Alignment.center,
        position: StyledToastPosition.bottom,
      );
      if (decodedMessage["type"] == "Update") {
        log("Update Message ${decodedMessage["id"]}");
        String sentDeviceName = decodedMessage["sender"];
        compareMessageId(
          receivedId: decodedMessage["id"],
          sentDeviceName: sentDeviceName,
          context: context,
        );
      }
      setState(() {
        // print("331: " + temp2['receiver'].toString());
        // print("332:" + temp2['type'].toString());
        // print("333|" + Global.myName.toString());
        // print(data['message'] + "can u hear meeeeeeeeeeeeeeeeeeeeeeeeeeeeee?");
        if (Global.cache.containsKey(decodedMessage["id"]) == false) {
          // print("line 338 test");

          if (decodedMessage["type"].toString() == 'Payload') {
            // print("line 341");

            Global.cache[decodedMessage["id"]] = Payload(
                decodedMessage["id"],
                decodedMessage['sender'],
                decodedMessage['receiver'],
                decodedMessage['message'],
                decodedMessage['Timestamp']);
            insertIntoMessageTable(Payload(
                decodedMessage["id"],
                decodedMessage['sender'],
                decodedMessage['receiver'],
                decodedMessage['message'],
                decodedMessage['Timestamp']));
            // print("current cache 344" + Global.cache.toString());
          } else {
            Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
            insertIntoMessageTable(Ack(decodedMessage["id"]));
          }
        } else if (Global.cache[decodedMessage["id"]].runtimeType == Payload) {
          if (decodedMessage["type"] == 'Ack') {
            //broadcast Ack last time to neighbours
            Global.cache.remove(decodedMessage["id"]);
            deleteFromMessageTable(decodedMessage["id"]);
          }
        } else {
          // cache has a ack form the same message id so i guess can keep track of the number of times we get acks?. currently ignore
          Global.cache.remove(decodedMessage["id"]);
          deleteFromMessageTable(decodedMessage["id"]);
        }
        print("350|" +
            decodedMessage['type'].toString() +
            ":Payload |" +
            decodedMessage['receiver'].toString() +
            ":" +
            Global.myName.toString());
        if (decodedMessage['type'] == "Payload" &&
            decodedMessage['receiver'] == Global.myName) {
          // Global.cache[temp2["id"]]!.broadcast = false;
          // if (Global.conversations[decodedMessage['sender']] == null) {
          //   Global.conversations[decodedMessage['sender']] = Map();
          // }
          Provider.of<Global>(context, listen: false)
              .receivedToConversations(decodedMessage, context);
          // If message type Payload, then add to cache and to conversations table
          // if not already present
          // if (!search(
          //     decodedMessage['sender'], decodedMessage["id"], context)) {
          //   Global.conversations[decodedMessage['sender']]![
          //       decodedMessage["id"]] = Msg(
          //     decodedMessage['message'],
          //     "received",
          //     decodedMessage['Timestamp'],
          //     decodedMessage["id"],
          //   );

          //   insertIntoConversationsTable(
          //       Msg(decodedMessage['message'], "received",
          //           decodedMessage['Timestamp'], decodedMessage["id"]),
          //       decodedMessage['sender']);
          // }
          if (Global.cache[decodedMessage["id"]] == null) {
            Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
            // print("280 test");
            insertIntoMessageTable(Ack(decodedMessage['id']));
          } else {
            Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
            updateMessageTable(decodedMessage["id"], Ack(decodedMessage['id']));
          }

          // print("355: ack added");
        } else {
          // Global.devices.forEach((element) {
          //   Global.nearbyService!
          //       .sendMessage(element.deviceId, data["message"].toString());
          // });
        }
      });
    });
  }

  void checkDevices() {
    Global.deviceSubscription =
        Global.nearbyService!.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        // if (element.state != SessionState.connected) connectToDevice(element);
        print(
            "deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

        if (Platform.isAndroid) {
          if (element.state == SessionState.connected) {
            Global.nearbyService!.stopBrowsingForPeers();
          } else {
            Global.nearbyService!.startBrowsingForPeers();
          }
        }
      });
      Provider.of<Global>(context, listen: false).updateDevices(devicesList);
      Provider.of<Global>(context, listen: false).updateConnectedDevices(
          devicesList.where((d) => d.state == SessionState.connected).toList());
      log('Devices length: ${devicesList.length}');
    });
  }

  Future refreshMessages() async {
    setState(() => isLoading = true);

    readAllUpdateCache();
    setState(() => isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    readAllUpdateConversation(context);
    init();
  }

  @override
  void dispose() {
    Global.deviceSubscription!.cancel();
    Global.receivedDataSubscription!.cancel();
    Global.nearbyService!.stopBrowsingForPeers();
    Global.nearbyService!.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("P2P Messaging"),
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Devices",
              ),
              Tab(
                text: "All Chats",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DevicesListScreen(
              deviceType: DeviceType.browser,
            ),
            ChatListScreen(),
          ],
        ),
      ),
    );
  }
}
