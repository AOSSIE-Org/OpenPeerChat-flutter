import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_nearby_connections_example/Payload.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'Global.dart';

import 'Msg.dart';
import 'ChatPage.dart';

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({required this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    Global.subscription!.cancel();
    Global.receivedDataSubscription!.cancel();
    Global.nearbyService!.stopBrowsingForPeers();
    Global.nearbyService!.stopAdvertisingPeer();
    super.dispose();
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
                                    return ChatPage(device);
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
                            onTap: () => _connectToDevice(device),
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
                                      Global.messages[index].deviceId +
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

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.black;
      case SessionState.connecting:
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  int getItemCount() {
    return Global.devices.length;
  }

  _connectToDevice(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        Global.nearbyService!.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        Global.nearbyService!.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void startBrowsing() async {
    await Global.nearbyService!.stopBrowsingForPeers();
    await Global.nearbyService!.startBrowsingForPeers();
  }

  void startAdvertising() async {
    await Global.nearbyService!.stopAdvertisingPeer();
    await Global.nearbyService!.startAdvertisingPeer();
  }

  // this function is supposed to broadcast all messages in the cache which is set to broadcast=true
  void broadcast() async {
    while (true) {
      Global.cache.forEach((key, value) {
        // if a message is supposed to be broadcasted to all devices in proximity then
        if (value.runtimeType == Payload && value.broadcast) {
          Payload payload = value;
          var data = {
            "sender": value.sender,
            "receiver": payload.receiver,
            "message": value.message,
            "id": key,
            "Timestamp": value.timestamp,
            "type": value.type
          };
          var toSend = jsonEncode(data);
          Global.devices.forEach((element) {
            print("270" + toSend);
            Global.nearbyService!
                .sendMessage(element.deviceId,toSend);
          });
        } else if (value.runtimeType == Ack) {
          Global.devices.forEach((element) {
            var data = {"id": "$key", "type": "$value.type"};
            Global.nearbyService!
                .sendMessage(element.deviceId, jsonEncode(data));
          });
        }
      });
      await Future.delayed(Duration(seconds: 10));
    }
  }

  void init() async {
    Global.nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
    }
    await Global.nearbyService!.init(
        serviceType: 'mpconn',
        deviceName: Global.myName,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
            startAdvertising();
            startBrowsing();
          }
        });
    Global.subscription =
        Global.nearbyService!.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((element) {
        if (element.state != SessionState.connected) _connectToDevice(element);
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
      // print("dataaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
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
        // var msg = jsonEncode(data['message']);
        String temp = data['message'];
        var temp2 = jsonDecode(temp);
        print("357: "+ temp2['receiver']);
        // print(temp+"dataaaaaaaaaaaaaaaaaaaaaaaa");

        print(data['message'] + "can u hear meeeeeeeeeeeeeeeeeeeeeeeeeeeeee?");
        if (Global.cache[temp2["id"]] == null) {
          if (temp2["type"] == 'Payload') {
            Global.cache[temp2["id"]] = Payload(
                temp2['sender'],
                temp2['receiver'],
                temp2['message'],
                temp2['timestamp']);
          } else {
            Global.cache[temp2["id"]] = Ack(temp2["id"]);
          }
        } else if (Global.cache[temp2["id"]].runtimeType == Payload) {
          if (temp2["type"] == 'Ack') {
            //broadcast Ack last time to neighbours
            Global.cache.remove(temp2["id"]);
          }
        } else {
          // cache has a ack form the same message id so i guess can keep track of the number of times we get acks?. currently ignore
          ;
        }

        if (temp2['type'] == "Payload" &&
            temp2['receiver'] == Global.myName) {
          Global.cache[temp2["id"]]!.broadcast = false;
          //send ack TODO
          Global.cache[temp2["id"]] = Ack(temp2["id"]);

          Global.messages
              .add(new Msg(data["deviceId"], data["message"], "received"));
          Global.conversations[data["deviceId"]]!.ListOfMsgs
              .add(new Msg(data["deviceId"], data["message"], "received"));
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
