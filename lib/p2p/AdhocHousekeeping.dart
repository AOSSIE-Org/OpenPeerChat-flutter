import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:flutter_nearby_connections_example/database/MessageDB.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:provider/provider.dart';
import '../classes/Global.dart';
import '../database/DatabaseHelper.dart';

// Get the state name of the connection
String getStateName(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return "Disconnected";
    case SessionState.connecting:
      return "Waiting";
    default:
      return "Connected";
  }
}

// Get the button state name of the connection
String getButtonStateName(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return "Connect";
    case SessionState.connecting:
      return "Connecting";
    default:
      return "Disconnect";
  }
}

// Get the state colour of the connection
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

// Get the button state colour of the connection
Color getButtonColor(SessionState state) {
  switch (state) {
    case SessionState.notConnected:
      return Colors.green;
    case SessionState.connecting:
      return Colors.yellow;
    default:
      return Colors.red;
  }
}

// Get the number of devices
int getItemCount(BuildContext context) {
  return Provider.of<Global>(context, listen: false).devices.length;
}

// Check if the id exists in the conversation list
bool search(String sender, String id, BuildContext context) {
  // Get from Provider
  if (Provider.of<Global>(context, listen: false).conversations[sender] !=
      null) {
    if (Provider.of<Global>(context, listen: false)
        .conversations[sender]!
        .containsKey(id)) {
      return true;
    }
  }

  return false;
}

// Function to connect to a device
void connectToDevice(Device device) {
  switch (device.state) {
    case SessionState.notConnected:
      Global.nearbyService!.invitePeer(
        deviceID: device.deviceId,
        deviceName: device.deviceName,
      );
      log("Want to connect");
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

// this function is supposed to broadcast all messages in the cache when the message ids don't match
void broadcast(BuildContext context) async {
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
        "type": "Payload"
      };
      var toSend = jsonEncode(data);
      Provider.of<Global>(
        context,
        listen: false,
      ).devices.forEach((element) {
        print("270" + toSend);
        Global.nearbyService!
            .sendMessage(element.deviceId, toSend); //make this async
      });
    } else if (value.runtimeType == Ack) {
      Provider.of<Global>(context, listen: false).devices.forEach((element) {
        var data = {"id": "$key", "type": "Ack"};
        Global.nearbyService!.sendMessage(element.deviceId, jsonEncode(data));
      });
    }
  });
  print("current cache:" + Global.cache.toString());
}

// Broadcasting update request message to the connected devices to recieve fresh messages that are yet to be recieved
void broadcastLastMessageID(BuildContext context) async {
  // Fetch from Database the last message.
  Timer.periodic(Duration(seconds: 3), (timer) async {
    String id = await MessageDB.instance.getLastMessageId(type: "received");
    log("Last message id: " + id);

    Provider.of<Global>(context, listen: false)
        .devices
        .forEach((element) async {
      var data = {
        "sender": Global.myName,
        "receiver": element.deviceName,
        "message": "__update__",
        "id": id,
        "Timestamp": DateTime.now().toString(),
        "type": "Update"
      };
      var toSend = jsonEncode(data);

      log("270" + toSend);
      await Global.nearbyService!.sendMessage(
        element.deviceId,
        toSend,
      );
    });
  });
}

// Compare message Ids
// If they are not same, the message needs to be broadcasted.
void compareMessageId({
  required String receivedId,
  required String sentDeviceName,
  required BuildContext context,
}) async {
  String sentId = await MessageDB.instance.getLastMessageId(type: "sent");
  if (sentId != receivedId) {
    broadcast(context);
  }
}

void checkDevices(BuildContext context) {
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

void init(BuildContext context) async {
  initiateNearbyService();
  checkDevices(context);
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

    if (Global.cache.containsKey(decodedMessage["id"]) == false) {
      if (decodedMessage["type"].toString() == 'Payload') {
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
      } else {
        Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
        insertIntoMessageTable(Ack(decodedMessage["id"]));
      }
    } else if (Global.cache[decodedMessage["id"]].runtimeType == Payload) {
      if (decodedMessage["type"] == 'Ack') {
        Global.cache.remove(decodedMessage["id"]);
        deleteFromMessageTable(decodedMessage["id"]);
      }
    } else {
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
      Provider.of<Global>(context, listen: false)
          .receivedToConversations(decodedMessage, context);
      if (Global.cache[decodedMessage["id"]] == null) {
        Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
        insertIntoMessageTable(Ack(decodedMessage['id']));
      } else {
        Global.cache[decodedMessage["id"]] = Ack(decodedMessage["id"]);
        updateMessageTable(decodedMessage["id"], Ack(decodedMessage['id']));
      }
    } else {}
  });
}

// Initiating NearbyService to start the connection
void initiateNearbyService() async {
  Global.nearbyService = NearbyService();
  await Global.nearbyService!.init(
    serviceType: 'mpconn',
    deviceName: Global.myName,
    strategy: Strategy.P2P_CLUSTER,
    callback: (isRunning) async {
      if (isRunning) {
        startAdvertising();
        startBrowsing();
      }
    },
  );
}
