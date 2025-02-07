import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:provider/provider.dart';
import '../classes/global.dart';

import 'chat_page.dart';
import '../p2p/adhoc_housekeeping.dart';

/// This is the DeviceListScreen page. This page task is to display the
/// devices in the range that are active now. It is used to manage the
/// connection between devices. We can either connect or disconnect
/// with any device in the range.
/// This is the Frontend of the Devices management, the backend is managed
/// with the help of Provider and AdhocHouseKeeping.

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({Key? key, required this.deviceType}) : super(key: key);

  final DeviceType deviceType;

  @override
 State<DevicesListScreen> createState() => _DevicesListScreenState();
}

class _DevicesListScreenState extends State<DevicesListScreen> {
  bool isInit = false;
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();
  List<Device> filteredDevices = [];
  Global? globalProvider;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_filterDevices);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isInit) {
      globalProvider = Provider.of<Global>(context, listen: false);
      globalProvider?.addListener(_handleGlobalUpdate);
      _updateFilteredDevices();
      isInit = true;
    }
  }

  void _handleGlobalUpdate() {
    if (mounted) {
      _updateFilteredDevices();
    }
  }

  void _updateFilteredDevices() {
    if (mounted) {
      setState(() {
        if (searchController.text.isEmpty) {
          filteredDevices = globalProvider?.devices ?? [];
        } else {
          _filterDevices();
        }
      });
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_filterDevices);
    globalProvider?.removeListener(_handleGlobalUpdate);
    searchController.dispose();
    super.dispose();
  }

  void _filterDevices() {
    if (mounted && globalProvider != null) {
      setState(() {
        filteredDevices = globalProvider!.devices
            .where((device) => parseDeviceInfo(device.deviceName)['name']!
            .toLowerCase()
            .contains(searchController.text.toLowerCase()))
            .toList();
      });
    }
  }

  String getCurrentName(String deviceName) {
    var deviceInfo = parseDeviceInfo(deviceName);
    String primaryKey = deviceInfo['primaryKey'] ?? '';
    // Get the latest name from Global
    return Provider.of<Global>(context, listen: true)
        .getUserName(primaryKey);
  }

  // Update the getCurrentName method to use StreamBuilder
  Widget buildDeviceName(String deviceName) {
    var deviceInfo = parseDeviceInfo(deviceName);
    String primaryKey = deviceInfo['primaryKey'] ?? '';
    return Selector<Global, String>(
      selector: (_, global) => global.getUserName(primaryKey),
      builder: (_, name, __) => Text(name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                hintStyle: TextStyle(color: Colors.grey.shade600),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
              ),
            ),
          ),
          ListView.builder(
            itemCount: filteredDevices.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final device = filteredDevices[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: buildDeviceName(device.deviceName), // Use the new method here
                      subtitle: Text(
                        parseDeviceInfo(device.deviceName)['primaryKey'] ?? '',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600
                        ),
                      ),
                      trailing: GestureDetector(
                        onTap: () => connectToDevice(device, context),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: getButtonColor(device.state),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          height: 35,
                          width: 100,
                          child: Center(
                            child: Text(
                              getButtonStateName(device.state),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        var deviceInfo = parseDeviceInfo(device.deviceName);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              converserName: Provider.of<Global>(context, listen: false)
                                  .getUserName(deviceInfo['primaryKey'] ?? ''),
                              converserId: deviceInfo['primaryKey'] ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.grey),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
