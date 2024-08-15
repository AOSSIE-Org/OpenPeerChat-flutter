// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:location/location.dart';
//
// class PermissionsStatusWidget extends StatefulWidget {
//   const PermissionsStatusWidget({Key? key}) : super(key: key);
//
//   @override
//   _PermissionsStatusWidgetState createState() => _PermissionsStatusWidgetState();
// }
//
// class _PermissionsStatusWidgetState extends State<PermissionsStatusWidget> {
//    Map<Permission, bool> _permissionsStatus = {
//     Permission.locationWhenInUse: false,
//     Permission.storage: false,
//     Permission.bluetooth: false,
//     Permission.bluetoothAdvertise: false,
//     Permission.bluetoothConnect: false,
//     Permission.bluetoothScan: false,
//     Permission.nearbyWifiDevices: false,
//   };
//
//   bool _locationServiceEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//   }
//
//   Future<void> _checkPermissions() async {
//     // Check the permissions and update the state
//     _permissionsStatus[Permission.locationWhenInUse] = await Permission.locationWhenInUse.isGranted;
//     _permissionsStatus[Permission.storage] = await Permission.storage.isGranted;
//     _permissionsStatus[Permission.bluetooth] = await Permission.bluetooth.isGranted;
//     _permissionsStatus[Permission.bluetoothAdvertise] = await Permission.bluetoothAdvertise.isGranted;
//     _permissionsStatus[Permission.bluetoothConnect] = await Permission.bluetoothConnect.isGranted;
//     _permissionsStatus[Permission.bluetoothScan] = await Permission.bluetoothScan.isGranted;
//     _permissionsStatus[Permission.nearbyWifiDevices] = await Permission.nearbyWifiDevices.isGranted;
//
//     // Check if location service is enabled
//     _locationServiceEnabled = await Location.instance.serviceEnabled();
//
//     setState(() {});
//   }
//
//   Future<void> _requestPermission(Permission permission) async {
//     await permission.request();
//     _checkPermissions();
//   }
//
//   Widget _buildPermissionRow(String label, Permission permission) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label),
//         GestureDetector(
//           onTap: () => _requestPermission(permission),
//           child: Icon(
//             _permissionsStatus[permission]! ? Icons.circle : Icons.circle_outlined,
//             color: _permissionsStatus[permission]! ? Colors.green : Colors.red,
//           ),
//         ),
//       ],
//     );
//   }
//
//    @override
//    Widget build(BuildContext context) {
//      return Center(
//          child: Padding(
//          padding: const EdgeInsets.all(8.0),
//      child: ListView(
//      children: <Widget>[
//      const Text(
//      "Permissions",
//      ),
//      Wrap(
//      children: <Widget>[
//      ElevatedButton(
//      child: const Text("checkLocationPermission (<= Android 12)"),
//      onPressed: () async {
//      if (await Permission.locationWhenInUse.isGranted) {
//      showSnackbar("Location permissions granted :)");
//      } else {
//      showSnackbar("Location permissions not granted :(");
//      }
//      },
//      ),
//      ElevatedButton(
//      child: const Text("askLocationPermission"),
//      onPressed: () async {
//      if (await Permission.locationWhenInUse
//          .request()
//          .isGranted) {
//      showSnackbar("Location permissions granted :)");
//      } else {
//      showSnackbar("Location permissions not granted :(");
//      }
//      },
//      ),
//      ElevatedButton(
//      child: const Text("checkExternalStoragePermission"),
//      onPressed: () async {
//      if (await Permission.storage.isGranted) {
//      showSnackbar("External Storage permissions granted :)");
//      } else {
//      showSnackbar(
//      "External Storage permissions not granted :(");
//      }
//      },
//      ),
//      ElevatedButton(
//      child: const Text("askExternalStoragePermission"),
//      onPressed: () {
//      Permission.storage.request();
//      },
//      ),
//      ElevatedButton(
//      child: const Text("checkBluetoothPermission (>= Android 12)"),
//      onPressed: () async {
//      if (!(await Future.wait([
//      Permission.bluetooth.isGranted,
//      Permission.bluetoothAdvertise.isGranted,
//      Permission.bluetoothConnect.isGranted,
//      Permission.bluetoothScan.isGranted,
//      ]))
//          .any((element) => false)) {
//      showSnackbar("Bluetooth permissions granted :)");
//      } else {
//      showSnackbar("Bluetooth permissions not granted :(");
//      }
//      },
//      ),
//      ElevatedButton(
//      child: const Text("askBluetoothPermission (Android 12+)"),
//      onPressed: () async {
//      await [
//      Permission.bluetooth,
//      Permission.bluetoothAdvertise,
//      Permission.bluetoothConnect,
//      Permission.bluetoothScan
//      ].request();
//      },
//      ),
//      ElevatedButton(
//      child: const Text(
//      "checkNearbyWifiDevicesPermission (>= Android 12)"),
//      onPressed: () async {
//      if (await Permission.nearbyWifiDevices.isGranted) {
//      showSnackbar("NearbyWifiDevices permissions granted :)");
//      } else {
//      showSnackbar(
//      "NearbyWifiDevices permissions not granted :(");
//      }
//      },
//      ),
//      ElevatedButton(
//      child: const Text(
//      "askNearbyWifiDevicesPermission (Android 12+)"),
//      onPressed: () {
//      Permission.nearbyWifiDevices.request();
//      },
//      ),
//      ],
//      ),
//      const Divider(),
//      const Text("Location Enabled"),
//      Wrap(
//      children: <Widget>[
//      ElevatedButton(
//      child: const Text("checkLocationEnabled"),
//      onPressed: () async {
//      if (await Location.instance.serviceEnabled()) {
//      showSnackbar("Location is ON :)");
//      } else {
//      showSnackbar("Location is OFF :(");
//      }
//      },
//      ),
//      ElevatedButton(
//      child: const Text("enableLocationServices"),
//      onPressed: () async {
//      if (await Location.instance.requestService()) {
//      showSnackbar("Location Service Enabled :)");
//      } else {
//      showSnackbar("Location Service not Enabled :(");
//      }
//      },
//      ),
//      ],
//      ),
//      ],
//      ),
//      ),
//      );
//   }
//
//   void showSnackbar(String s) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
//   }
// }
