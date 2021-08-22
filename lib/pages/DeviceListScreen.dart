import 'dart:convert';
import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_nearby_connections_example/database/DatabaseHelper.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/p2p/MatrixServerModel.dart';
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
    init();
    refreshMessages();
    print(" 37 reloaded:" + Global.cache.toString());
  }

  Future refreshMessages() async {
    setState(() => isLoading = true);

    readAllUpdateCache();
    readAllUpdateConversation();
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    Global.subscription!.cancel();
    Global.receivedDataSubscription!.cancel();
    Global.nearbyService!.stopBrowsingForPeers();
    Global.nearbyService!.stopAdvertisingPeer();
    super.dispose();
  }

  var _selectedIndex = 0;
  Widget getBody(BuildContext context) {
    switch (_selectedIndex) {
      case 0:
      // return showTrips(context);
      case 1:
      // return search(widget.account);
      case 2:
        return Text('Not yet implemented!');
      default:
        throw UnimplementedError();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Devices"),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text("Chats"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            title: Text("Available"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            title: Text("Profile"),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: Container(
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
              itemCount: getItemCount(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final device = Global.devices[index];
                return Container(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ChatPage(Contact(device.deviceName));
                                  },
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Text(device.deviceName),
                                Text(
                                  getStateName(device.state),
                                  style: TextStyle(
                                      color: getStateColor(device.state)),
                                ),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          )),
                          // Request connect
                          GestureDetector(
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
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey,
                      ),
                      Text("hello"),
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: Global.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 15,
                              // color: Colors.amber[colorCodes[index]],
                              child: Center(
                                  child: Text(Global.messages[index].msgtype +
                                      ":" +
                                      " " +
                                      Global.messages[index].message)),
                            );
                          }),
                    ],
                  ),
                );
              })
        ],
      )),
    );
  }

  void init() async {
    initiateNearbyService();
    Global.subscription =
        Global.nearbyService!.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        if (element.state != SessionState.connected) connectToDevice(element);
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

      setState(() {
        Global.devices.clear();
        Global.devices.addAll(devicesList);
        Global.connectedDevices.clear();
        Global.connectedDevices.addAll(devicesList
            .where((d) => d.state == SessionState.connected)
            .toList());
      });
    });
    broadcast();
    Global.receivedDataSubscription =
        Global.nearbyService!.dataReceivedSubscription(callback: (data) {
      print("dataReceivedSubscription: ${jsonEncode(data)}");

      showToast(jsonEncode(data),
          context: context,
          axis: Axis.horizontal,
          alignment: Alignment.center,
          position: StyledToastPosition.bottom);
      // Global.devices.forEach((element) {
      //   Global.nearbyService!
      //       .sendMessage(element.deviceId, data["message"].toString());});

      setState(() {
        String temp = data['message'];
        var temp2 = jsonDecode(temp);
        print("331: " + temp2['receiver'].toString());
        print("332:" + temp2['type'].toString());
        print("333|" + Global.myName.toString());
        print(data['message'] + "can u hear meeeeeeeeeeeeeeeeeeeeeeeeeeeeee?");
        if (Global.cache.containsKey(temp2["id"]) == false) {
          print("line 338 test");
          if (temp2["type"].toString() == 'Payload') {
            print("line 341");

            Global.cache[temp2["id"]] = Payload(temp2["id"], temp2['sender'],
                temp2['receiver'], temp2['message'], temp2['Timestamp']);
            insertIntoMessageTable(Payload(temp2["id"], temp2['sender'],
                temp2['receiver'], temp2['message'], temp2['Timestamp']));
            print("current cache 344" + Global.cache.toString());
          } else {
            Global.cache[temp2["id"]] = Ack(temp2["id"]);
            insertIntoMessageTable(Ack(temp2["id"]));
          }
        } else if (Global.cache[temp2["id"]].runtimeType == Payload) {
          if (temp2["type"] == 'Ack') {
            //broadcast Ack last time to neighbours
            Global.cache.remove(temp2["id"]);
            deleteFromMessageTable(temp2["id"]);
          }
        } else {
          // cache has a ack form the same message id so i guess can keep track of the number of times we get acks?. currently ignore
          Global.cache.remove(temp2["id"]);
          deleteFromMessageTable(temp2["id"]);
          ;
        }
        print("350|" +
            temp2['type'].toString() +
            ":Payload |" +
            temp2['receiver'].toString() +
            ":" +
            Global.myName.toString());
        if (temp2['type'] == "Payload" && temp2['receiver'] == Global.myName) {
          // Global.cache[temp2["id"]]!.broadcast = false;
          if (Global.conversations[temp2['sender']] == null) {
            Global.conversations[temp2['sender']] = [];
          }
          Global.conversations[temp2['sender']]!.add({
            temp2["id"]: Msg(
                temp2['message'], "received", temp2['Timestamp'], temp2["id"])
          });
          insertIntoConversationsTable(
              Msg(temp2['message'], "received", temp2['Timestamp'],
                  temp2["id"]),
              temp2['sender']);
          if (Global.cache[temp2["id"]] == null) {
            Global.cache[temp2["id"]] = Ack(temp2["id"]);
            print("280 test");
            insertIntoMessageTable(Ack(temp2['id']));
          } else {
            Global.cache[temp2["id"]] = Ack(temp2["id"]);
            updateMessageTable(temp2["id"], Ack(temp2['id']));
          }

          print("355: ack added");
          // Global.messages
          //     .add(new Msg(data["deviceId"], data["message"], "received"));
          // Global.conversations[data["deviceId"]]!.ListOfMsgs
          //     .add(new Msg(data["sender"], data["message"], "received"));
        } else {
          // Global.devices.forEach((element) {
          //   Global.nearbyService!
          //       .sendMessage(element.deviceId, data["message"].toString());
          // });
        }
      });
    });
  }
}
