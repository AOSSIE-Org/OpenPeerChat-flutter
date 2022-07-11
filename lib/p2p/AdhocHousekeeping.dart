import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:flutter_nearby_connections_example/database/MessageDB.dart';
import 'package:provider/provider.dart';
import '../classes/Global.dart';

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
  // if (Global.conversations[sender] == null) return false;

  // if (Global.conversations[sender]!.containsKey(id)) {
  //   return true;
  // }
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
      Provider.of<Global>(context, listen: false).devices.forEach((element) {
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

// void checkForMessageUpdates() async {
//   broadcastLastMessageID();
//   Global.receivedDataSubscription!.onData((data) {
//     // print("dataReceivedSubscription: ${jsonEncode(data)}");
//     var decodedMessage = jsonDecode(data["message"]);

//     // checking if successfully recieving the update or not
//     if (decodedMessage["type"] == "Update") {
//       log("Update Message ${decodedMessage["id"]}");
//       String sentDeviceName = decodedMessage["sender"];
//       compareMessageId(
//         receivedId: decodedMessage["id"],
//         sentDeviceName: sentDeviceName,
//       );
//     }
//   });
// }

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
