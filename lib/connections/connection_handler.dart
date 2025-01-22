import 'dart:async';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class ConnectionHandler {
  final NearbyService nearbyService = NearbyService();
  final List<Device> devices = [];
  final List<Device> connectedDevices = [];
  StreamSubscription? deviceSubscription;
  StreamSubscription? receivedDataSubscription;

  /// Initialize the Nearby Service
  Future<void> initialize({required String userName}) async {
    await nearbyService.init(
      serviceType: 'your_service_type', // Replace with your service type.
      deviceName: userName,
      strategy: Strategy.P2P_CLUSTER, callback: null,
    );
    await nearbyService.startAdvertisingPeer();
    await nearbyService.startBrowsingForPeers();

    _listenToDeviceChanges();
    _listenToReceivedData();
  }

  /// Listen for changes in available devices.
  void _listenToDeviceChanges() {
    deviceSubscription = nearbyService.stateChangedSubscription(callback: (devicesList) {
      devices
        ..clear()
        ..addAll(devicesList);

      // Filter connected devices
      connectedDevices
        ..clear()
        ..addAll(devicesList.where((device) => device.state == SessionState.connected));
    });
  }

  /// Listen for received data from peers.
  void _listenToReceivedData() {
    receivedDataSubscription = nearbyService.dataReceivedSubscription(callback: (data) {
      // Handle received data here
      print("Data received: ${data['message']}");
    });
  }

  /// Send a message to a specific device.
  Future<void> sendMessage(Device device, String message) async {
    await nearbyService.sendMessage(device.deviceId, message);
  }

  /// Disconnect from a device.
  Future<void> disconnectDevice(Device device) async {
    await nearbyService.disconnectPeer(deviceID: device.deviceId);
  }

  /// Cleanup resources when done.
  Future<void> dispose() async {
    await deviceSubscription?.cancel();
    await receivedDataSubscription?.cancel();
    await nearbyService.stopAdvertisingPeer();
    await nearbyService.stopBrowsingForPeers();
  }
}
