import 'dart:async';
import 'dart:convert';
import 'dart:io';

// import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_nearby_connections_example/classes/Payload.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import '../classes/Global.dart';
import '../classes/Msg.dart';

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
          "type": "Payload"
        };
        var toSend = jsonEncode(data);
        Global.devices.forEach((element) {
          print("270" + toSend);
          Global.nearbyService!
              .sendMessage(element.deviceId, toSend); //make this async
        });
      } else if (value.runtimeType == Ack) {
        Global.devices.forEach((element) {
          var data = {"id": "$key", "type": "Ack"};
          Global.nearbyService!.sendMessage(element.deviceId, jsonEncode(data));
        });
      }
    });
    print("current cache:" + Global.cache.toString());
    await Future.delayed(Duration(seconds: 10));
  }
}

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
      });
}
