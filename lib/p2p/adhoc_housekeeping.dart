import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_nearby_connections_example/classes/payload.dart';
import 'package:flutter_nearby_connections_example/database/message_db.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';
import '../database/database_helper.dart';
import "package:pointycastle/export.dart";
import '../database/model.dart';
import '../encyption/rsa.dart';

/// This is the Adhoc part where the messages are received and sent.
/// Each and every function have there purpose mentioned above them.

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

      break;
    case SessionState.connected:

      Global.nearbyService!.disconnectPeer(deviceID: device.deviceId);
      break;
    case SessionState.connecting:

      break;
  }
}

// Start discovering devices
void startBrowsing() async {
  await Global.nearbyService!.stopBrowsingForPeers();
  await Global.nearbyService!.startBrowsingForPeers();
}

void startAdvertising() async {
  await Global.nearbyService!.stopAdvertisingPeer();
  await Global.nearbyService!.startAdvertisingPeer();
}


  //
// This function is supposed to broadcast all messages in the cache
// when the message ids don't match
void broadcast(BuildContext context) async {
  Global.cache.forEach((key, value) async {
    // if a message is supposed to be broadcasted to all devices in proximity then
    if (value.runtimeType == Payload && value.broadcast) {
      if(Global.publicKeys[value.receiver] != null ) {

        Payload payload = value;

        // Get the public key of the receiver
        RSAPublicKey publicKey = Global.publicKeys[value.receiver]!;
        dynamic message = jsonDecode(payload.message);

        var finalData = {};
        if (message['type'] == 'text') {
          Uint8List encryptedBytes = utf8.encode(message['data']);
          // Encrypt the message
          Uint8List encryptedMessage = rsaEncrypt(publicKey, encryptedBytes);
          // Encode the message to base64
           String encodedMessage = base64.encode(encryptedMessage);
           finalData = {
            "type": "text",
            "data": encodedMessage,
          };
        }
        else if (message['type'] == 'voice' || message['type'] == 'file') {
          File file = File(message['filePath']);
          Uint8List encryptedBytes = await file.readAsBytes();

          //to send the file encrypted with the RSA
          // Encrypt the message
          // Uint8List encryptedMessage = rsaEncrypt(publicKey, encryptedBytes);
          // Encode the message to base64
          // String encodedMessage = base64.encode(encryptedMessage);


          String encodedMessage = base64.encode(encryptedBytes);



           finalData = {
            "type": message['type'],
            "data": encodedMessage,
            "fileName": message['fileName'],
          };
        }

        // Create the data to be sent
        var data = {
          "sender": payload.sender,
          "receiver": payload.receiver,
          "message": jsonEncode(finalData),
          "id": key,
          "Timestamp": payload.timestamp,
          "type": "Payload"
        };
        // Encode the data to json

      var toSend = jsonEncode(data);
        if (!context.mounted) return;
        Provider.of<Global>(
        context,
        listen: false,
      ).devices.forEach((element) {

        Global.nearbyService!
            .sendMessage(element.deviceId, toSend);
      });
    }
    } else if (value.runtimeType == Ack) {
      Provider.of<Global>(context, listen: false).devices.forEach((element) {
        var data = {"id": key, "type": "Ack"};
        Global.nearbyService!.sendMessage(element.deviceId, jsonEncode(data));
      });
    }
  });
}

// Broadcasting update request message to the connected devices to receive
// fresh messages that are yet to be recieved
void broadcastLastMessageID(BuildContext context) async {
  // Fetch from Database the last message.
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    String id = await MessageDB.instance.getLastMessageId(type: "received");
    if (!context.mounted) return;
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


      await Global.nearbyService!.sendMessage(
        element.deviceId,
        toSend,
      );
    });
  });
}


void sendPublicKey(BuildContext context) async {
  // Fetch from Database the last message.
  String id = await MessageDB.instance.getLastMessageId(type: "received");

    String publicKeyPem = encodePublicKeyToPem(Global.myPublicKey!);

  if (!context.mounted) return;
    Provider.of<Global>(context, listen: false)
        .devices
        .forEach((element) async {
      var data = {
        "sender": Global.myName,
        "receiver": element.deviceName,
        "message":  publicKeyPem,
        "id": id,
        "Timestamp": DateTime.now().toString(),
        "type": "PublicKey"
      };
      var toSend = jsonEncode(data);


      await Global.nearbyService!.sendMessage(

        element.deviceId,
        toSend,
      );
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
    if (!context.mounted) return;
    broadcast(context);
  }
}

void checkDevices(BuildContext context) {
  Global.deviceSubscription =
      Global.nearbyService!.stateChangedSubscription(callback: (devicesList) {
        for (var element in devicesList) {

          // If the device is connected, send the public key
          if (element.state == SessionState.connected) {
            sendPublicKey(context);
          }

          if (Platform.isAndroid) {
            if (element.state == SessionState.connected) {
              Global.nearbyService!.stopBrowsingForPeers();
            } else {
              Global.nearbyService!.startBrowsingForPeers();
            }
          }
        }

        Provider.of<Global>(context, listen: false).updateDevices(devicesList);
        Provider.of<Global>(context, listen: false).updateConnectedDevices(
            devicesList.where((d) => d.state == SessionState.connected).toList());
      });
}


// The the protocol service. It receives the messages from the
// dataReceivedSubscription service and decode it.
void init(BuildContext context) async {

   initiateNearbyService();
  checkDevices(context);

  broadcastLastMessageID(context);

  Global.receivedDataSubscription =
      Global.nearbyService!.dataReceivedSubscription(callback: (data) async {

        var decodedMessage = jsonDecode(data['message']);

        if (decodedMessage['type'] == 'PublicKey') {

          String sentDeviceName = decodedMessage["sender"];
          String publicKeyPem = decodedMessage['message'];
          RSAPublicKey publicKey = parsePublicKeyFromPem(publicKeyPem);
          Global.publicKeys[sentDeviceName] = publicKey;

          //string to uint8list
          List<int> list = publicKeyPem.codeUnits;
          Uint8List bytes = Uint8List.fromList(list);

          // Store the public key in the database
          MessageDB.instance.insertPublicKey(PublicKeyFromDB(sentDeviceName, bytes));
        }

    else if (decodedMessage["type"] == "Update") {
      String sentDeviceName = decodedMessage["sender"];
      compareMessageId(
        receivedId: decodedMessage["id"],
        sentDeviceName: sentDeviceName,
        context: context,
      );
    }

    else if (Global.cache.containsKey(decodedMessage["id"]) == false) {
      if (decodedMessage["type"].toString() == 'Payload') {

          Global.cache[decodedMessage["id"]] = Payload(
              decodedMessage["id"],
              decodedMessage['sender'],
              decodedMessage['receiver'],
              decodedMessage['message'],
              decodedMessage['Timestamp']
          );
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
    }

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

