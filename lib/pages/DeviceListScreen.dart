import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_nearby_connections_example/database/DatabaseHelper.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../classes/Global.dart';

import '../classes/Msg.dart';
import 'ChatPage.dart';
import '../p2p/AdhocHousekeeping.dart';

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({required this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  bool isInit = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // init();
    // print(" 37 reloaded:" + Global.cache.toString());
    // checkForMessageUpdates();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   refreshMessages();
  // }

  // Future refreshMessages() async {
  //   setState(() => isLoading = true);
  //   log("refreshing messages");
  //   readAllUpdateCache();
  //   readAllUpdateConversation(context);
  //   setState(() => isLoading = false);
  // }

  var _selectedIndex = 0;

  // Widget getBody(BuildContext context) {
  //   switch (_selectedIndex) {
  //     case 0:
  //     // return showTrips(context);
  //     case 1:
  //     // return search(widget.account);
  //     case 2:
  //       return Text('Not yet implemented!');
  //     default:
  //       throw UnimplementedError();
  //   }
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            ListView.builder(
              itemCount: Provider.of<Global>(context).devices.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final device = Provider.of<Global>(context).devices[index];
                return Container(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(device.deviceName),
                        subtitle: Text(
                          getStateName(device.state),
                          style: TextStyle(color: getStateColor(device.state)),
                        ),
                        trailing: GestureDetector(
                          onTap: () => connectToDevice(device),
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            padding: EdgeInsets.all(8.0),
                            height: 35,
                            width: 100,
                            color: getButtonColor(device.state),
                            child: Center(
                              child: Text(
                                getButtonStateName(device.state),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatPage(
                                  converser: device.deviceName,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Check for devices in proximity
  // void checkDevices() {
  //   Global.deviceSubscription =
  //       Global.nearbyService!.stateChangedSubscription(callback: (devicesList) {
  //     devicesList.forEach((element) {
  //       // if (element.state != SessionState.connected) connectToDevice(element);
  //       print(
  //           "deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

  //       if (Platform.isAndroid) {
  //         if (element.state == SessionState.connected) {
  //           Global.nearbyService!.stopBrowsingForPeers();
  //         } else {
  //           Global.nearbyService!.startBrowsingForPeers();
  //         }
  //       }
  //     });

  //     setState(() {
  //       Global.devices.clear();
  //       Global.devices.addAll(devicesList);
  //       Global.connectedDevices.clear();
  //       Global.connectedDevices.addAll(devicesList
  //           .where((d) => d.state == SessionState.connected)
  //           .toList());
  //     });
  //   });
  // }

  // The function responsible for receiving the messages
  // void init() async {
  //   initiateNearbyService();
  //   checkDevices();
  //   broadcastLastMessageID();
  //   Global.receivedDataSubscription =
  //       Global.nearbyService!.dataReceivedSubscription(callback: (data) {
  //     var decodedMessage = jsonDecode(data['message']);
  //     showToast(
  //       jsonEncode(data),
  //       context: context,
  //       axis: Axis.horizontal,
  //       alignment: Alignment.center,
  //       position: StyledToastPosition.bottom,
  //     );
  //     if (decodedMessage["type"] == "Update") {
  //       log("Update Message ${decodedMessage["id"]}");
  //       String sentDeviceName = decodedMessage["sender"];
  //       compareMessageId(
  //         receivedId: decodedMessage["id"],
  //         sentDeviceName: sentDeviceName,
  //       );
  //     }
  //     setState(() {
  //       // print("331: " + temp2['receiver'].toString());
  //       // print("332:" + temp2['type'].toString());
  //       // print("333|" + Global.myName.toString());
  //       // print(data['message'] + "can u hear meeeeeeeeeeeeeeeeeeeeeeeeeeeeee?");
  //       if (Global.cache.containsKey(decodedMessage["id"]) == false) {
  //         // print("line 338 test");

  //         if (decodedMessage["type"].toString() == 'Payload') {
  //           // print("line 341");

  //           Global.cache[decodedMessage["id"]] = Payload(
  //               decodedMessage["id"],
  //               decodedMessage['sender'],
  //               decodedMessage['receiver'],
  //               decodedMessage['message'],
  //               decodedMessage['Timestamp']);
  //           insertIntoMessageTable(Payload(
  //               decodedMessage["id"],
  //               decodedMessage['sender'],
  //               decodedMessage['receiver'],
  //               decodedMessage['message'],
  //               decodedMessage['Timestamp']));
  //           // print("current cache 344" + Global.cache.toString());
  //         } else {
  //           Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
  //           insertIntoMessageTable(Ack(decodedMessage["id"]));
  //         }
  //       } else if (Global.cache[decodedMessage["id"]].runtimeType == Payload) {
  //         if (decodedMessage["type"] == 'Ack') {
  //           //broadcast Ack last time to neighbours
  //           Global.cache.remove(decodedMessage["id"]);
  //           deleteFromMessageTable(decodedMessage["id"]);
  //         }
  //       } else {
  //         // cache has a ack form the same message id so i guess can keep track of the number of times we get acks?. currently ignore
  //         Global.cache.remove(decodedMessage["id"]);
  //         deleteFromMessageTable(decodedMessage["id"]);
  //       }
  //       print("350|" +
  //           decodedMessage['type'].toString() +
  //           ":Payload |" +
  //           decodedMessage['receiver'].toString() +
  //           ":" +
  //           Global.myName.toString());
  //       if (decodedMessage['type'] == "Payload" &&
  //           decodedMessage['receiver'] == Global.myName) {
  //         // Global.cache[temp2["id"]]!.broadcast = false;
  //         // if (Global.conversations[decodedMessage['sender']] == null) {
  //         //   Global.conversations[decodedMessage['sender']] = Map();
  //         // }
  //         Provider.of<Global>(context, listen: false)
  //             .receivedToConversations(decodedMessage, context);
  //         // If message type Payload, then add to cache and to conversations table
  //         // if not already present
  //         // if (!search(
  //         //     decodedMessage['sender'], decodedMessage["id"], context)) {
  //         //   Global.conversations[decodedMessage['sender']]![
  //         //       decodedMessage["id"]] = Msg(
  //         //     decodedMessage['message'],
  //         //     "received",
  //         //     decodedMessage['Timestamp'],
  //         //     decodedMessage["id"],
  //         //   );

  //         //   insertIntoConversationsTable(
  //         //       Msg(decodedMessage['message'], "received",
  //         //           decodedMessage['Timestamp'], decodedMessage["id"]),
  //         //       decodedMessage['sender']);
  //         // }
  //         if (Global.cache[decodedMessage["id"]] == null) {
  //           Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
  //           // print("280 test");
  //           insertIntoMessageTable(Ack(decodedMessage['id']));
  //         } else {
  //           Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
  //           updateMessageTable(decodedMessage["id"], Ack(decodedMessage['id']));
  //         }

  //         // print("355: ack added");
  //       } else {
  //         // Global.devices.forEach((element) {
  //         //   Global.nearbyService!
  //         //       .sendMessage(element.deviceId, data["message"].toString());
  //         // });
  //       }
  //     });
  //   });
  // }
}
