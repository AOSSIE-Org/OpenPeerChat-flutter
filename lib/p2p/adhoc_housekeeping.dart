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

// Helper function to parse device info
Map<String, String> parseDeviceInfo(String deviceName) {
  final parts = deviceName.split(':');
  return {
    'name': parts[0],
    'primaryKey': parts.length > 1 ? parts[1] : '',
  };
}

// Check if the id exists in the conversation list
bool search(String senderKey, String id, BuildContext context) {
  if (Provider.of<Global>(context, listen: false).conversations[senderKey] != null) {
    return Provider.of<Global>(context, listen: false)
        .conversations[senderKey]!
        .containsKey(id);
  }
  return false;
}

// Function to connect to a device
void connectToDevice(Device device, BuildContext context) async {
  var deviceInfo = parseDeviceInfo(device.deviceName);
  String primaryKey = deviceInfo['primaryKey'] ?? '';
  String name = deviceInfo['name'] ?? '';

  if (primaryKey.isNotEmpty) {
    await MessageDB.instance.upsertUserName(primaryKey, name);
    // Update Global provider
    Provider.of<Global>(context, listen: false).handleProfileUpdate(primaryKey, name);
  }

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

// New function to broadcast profile updates
// Enhanced profile update broadcast
void broadcastProfileUpdate(BuildContext context) {
  final message = {
    'type': 'profile_update',
    'primaryKey': Global.primaryKey,
    'name': Global.myName,
    'timestamp': DateTime.now().toIso8601String(),
  };

  for (var device in Provider.of<Global>(context, listen: false).connectedDevices) {
    Global.nearbyService?.sendMessage(
      device.deviceId,
      jsonEncode(message),
    );
  }
}

// Add profile update handling to your message receiving logic
void handleIncomingMessage(dynamic message, BuildContext context) {
  final decoded = jsonDecode(message);

  if (decoded['type'] == 'profile_update') {
    Provider.of<Global>(context, listen: false).handleProfileUpdate(
      decoded['primaryKey'],
      decoded['name'],
    );
    // Send acknowledgment of profile update
    sendProfileUpdateAck(decoded['primaryKey'], context);
  }
}

void sendProfileUpdateAck(String targetPrimaryKey, BuildContext context) {
  final ackMessage = {
    'type': 'profile_update_ack',
    'primaryKey': Global.primaryKey,
    'targetKey': targetPrimaryKey,
    'timestamp': DateTime.now().toIso8601String(),
  };

  Provider.of<Global>(context, listen: false).devices.forEach((device) {
    var deviceInfo = parseDeviceInfo(device.deviceName);
    if (deviceInfo['primaryKey'] == targetPrimaryKey) {
      Global.nearbyService?.sendMessage(
        device.deviceId,
        jsonEncode(ackMessage),
      );
    }
  });
}

// This function is supposed to broadcast all messages in the cache
// when the message ids don't match
void broadcast(BuildContext context) async {
  Global.cache.forEach((key, value) async {
    if (value.runtimeType == Payload && value.broadcast) {
      if(Global.publicKeys[value.receiverId] != null) {
        Payload payload = value;
        RSAPublicKey publicKey = Global.publicKeys[value.receiverId]!;
        dynamic message = jsonDecode(payload.message);

        var finalData = {};
        if (message['type'] == 'text') {
          Uint8List encryptedBytes = utf8.encode(message['data']);
          Uint8List encryptedMessage = rsaEncrypt(publicKey, encryptedBytes);
          String encodedMessage = base64.encode(encryptedMessage);
          finalData = {
            "type": "text",
            "data": encodedMessage,
          };
        }
        else if (message['type'] == 'voice' || message['type'] == 'file') {
          File file = File(message['filePath']);
          Uint8List encryptedBytes = await file.readAsBytes();
          String encodedMessage = base64.encode(encryptedBytes);
          finalData = {
            "type": message['type'],
            "data": encodedMessage,
            "fileName": message['fileName'],
          };
        }

        var data = {
          "sender": payload.sender,
          "senderKey": Global.primaryKey,
          "receiver": payload.receiver,
          "receiverKey": payload.receiverId,
          "message": jsonEncode(finalData),
          "id": key,
          "Timestamp": payload.timestamp,
          "type": "Payload"
        };

        var toSend = jsonEncode(data);
        if (!context.mounted) return;

        Provider.of<Global>(context, listen: false).devices.forEach((element) {
          var deviceInfo = parseDeviceInfo(element.deviceName);
          String targetDeviceId = deviceInfo['primaryKey'] ?? '';

          if (targetDeviceId == payload.receiverId) {
            Global.nearbyService!.sendMessage(element.deviceId, toSend);
          }
        });
      }
    } else if (value.runtimeType == Ack) {
      Provider.of<Global>(context, listen: false).devices.forEach((element) {
        var deviceInfo = parseDeviceInfo(element.deviceName);
        String targetDeviceId = deviceInfo['primaryKey'] ?? '';

        var data = {
          "id": key,
          "type": "Ack",
          "senderKey": Global.primaryKey
        };

        // Send Ack to all connected devices
        if (targetDeviceId.isNotEmpty) {
          Global.nearbyService!.sendMessage(element.deviceId, jsonEncode(data));
        }
      });
    }
  });
}


// Broadcasting update request message to the connected devices to receive
// fresh messages that are yet to be recieved
// Updated broadcastLastMessageID with primary key handling
void broadcastLastMessageID(BuildContext context) async {
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    String id = await MessageDB.instance.getLastMessageId(type: "received");
    if (!context.mounted) return;
    Provider.of<Global>(context, listen: false).devices.forEach((element) async {
      var deviceInfo = parseDeviceInfo(element.deviceName);
      if (deviceInfo['primaryKey']?.isNotEmpty ?? false) {
        var data = {
          "sender": Global.myName,
          "senderKey": Global.primaryKey,
          "receiver": deviceInfo['name'],
          "receiverKey": deviceInfo['primaryKey'],
          "message": "__update__",
          "id": id,
          "Timestamp": DateTime.now().toString(),
          "type": "Update"
        };
        await Global.nearbyService!.sendMessage(element.deviceId, jsonEncode(data));
      }
    });
  });
}



// Updated sendPublicKey with primary key handling
// Update sendPublicKey to use correct device mapping
void sendPublicKey(BuildContext context) async {
  String id = await MessageDB.instance.getLastMessageId(type: "received");
  String publicKeyPem = encodePublicKeyToPem(Global.myPublicKey!);

  Provider.of<Global>(context, listen: false).devices.forEach((element) async {
    var deviceInfo = parseDeviceInfo(element.deviceName);
    String targetDeviceId = deviceInfo['primaryKey'] ?? '';

    if (targetDeviceId.isNotEmpty) {
      var data = {
        "sender": Global.myName,
        "senderKey": Global.primaryKey,
        "receiver": deviceInfo['name'],
        "receiverKey": targetDeviceId,
        "message": publicKeyPem,
        "id": id,
        "Timestamp": DateTime.now().toString(),
        "type": "PublicKey"
      };
      await Global.nearbyService!.sendMessage(element.deviceId, jsonEncode(data));
    }
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

void startPeriodicProfileSync(BuildContext context) {
  Timer.periodic(const Duration(minutes: 5), (timer) {
    if (Provider.of<Global>(context, listen: false).connectedDevices.isNotEmpty) {
      broadcastProfileUpdate(context);
    }
  });
}

void initializeProfileSync(BuildContext context) {
  final global = Provider.of<Global>(context, listen: false);
  if (global.connectedDevices.isNotEmpty) {
    broadcastProfileUpdate(context);
  }
}


void checkDevices(BuildContext context) {
  Global.deviceSubscription =
      Global.nearbyService!.stateChangedSubscription(callback: (devicesList) {
        for (var element in devicesList) {
          if (element.state == SessionState.connected) {
            sendPublicKey(context);
            broadcastProfileUpdate(context);
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

        switch (decodedMessage['type']) {
          case 'profile_update':
            Provider.of<Global>(context, listen: false).handleProfileUpdate(
              decodedMessage['primaryKey'],
              decodedMessage['name'],
            );
            break;

          case 'PublicKey':
            handlePublicKeyMessage(decodedMessage);
            break;

          case 'Update':
            compareMessageId(
              receivedId: decodedMessage["id"],
              sentDeviceName: decodedMessage["senderKey"],
              context: context,
            );
            break;

          case 'Payload':
            await handlePayloadMessage(decodedMessage, context);
            break;

          default:
            if (!Global.cache.containsKey(decodedMessage["id"])) {
              handleCacheUpdate(decodedMessage);
            }
        }
      });
}

void handlePublicKeyMessage(Map<String, dynamic> message) {
  String senderKey = message["senderKey"];
  String publicKeyPem = message['message'];
  RSAPublicKey publicKey = parsePublicKeyFromPem(publicKeyPem);
  Global.publicKeys[senderKey] = publicKey;

  List<int> list = publicKeyPem.codeUnits;
  Uint8List bytes = Uint8List.fromList(list);
  MessageDB.instance.insertPublicKey(PublicKeyFromDB(senderKey, bytes));
}

Future<void> handlePayloadMessage(Map<String, dynamic> message, BuildContext context) async {
  if (!Global.cache.containsKey(message["id"])) {
    Global.cache[message["id"]] = Payload(
      message["id"],
      message['sender'],
      message['receiver'],
      message['message'],
      message['Timestamp'],
      senderId: message['senderKey'],
      receiverId: message['receiverKey'],
    );
    insertIntoMessageTable(Global.cache[message["id"]]);
  }

  if (message['receiverKey'] == Global.primaryKey) {
    Provider.of<Global>(context, listen: false)
        .receivedToConversations(message, context);

    var ack = Ack(message["id"], senderKey: Global.primaryKey);
    Global.cache[message["id"]] = ack;

    if (Global.cache[message["id"]] == null) {
      insertIntoMessageTable(ack);
    } else {
      updateMessageTable(message["id"], ack);
    }
  }
}

void handleCacheUpdate(Map<String, dynamic> message) {
  if (!message.containsKey("id")) return;
  final messageId = message["id"]?.toString();
  if (messageId == null) return;

  var ack = Ack(messageId, senderKey: Global.primaryKey);
  Global.cache[messageId] = ack;
  insertIntoMessageTable(ack);
}

// Initiating NearbyService to start the connection
// Updated initiateNearbyService with primary key
void initiateNearbyService() async {
  Global.nearbyService = NearbyService();
  await Global.nearbyService!.init(
    serviceType: 'mpconn',
    deviceName: '${Global.myName}:${Global.primaryKey}',
    strategy: Strategy.P2P_CLUSTER,
    callback: (isRunning) async {
      if (isRunning) {
        startAdvertising();
        startBrowsing();
      }
    },
  );
}

