import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
                contentPadding: const EdgeInsets.all(8),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade100)),
              ),
            ),
          ),
          ListView.builder(
            // Builds a screen with list of devices in the proximity
            itemCount: Provider.of<Global>(context).devices.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              // Getting a device from the provider
              final device = Provider.of<Global>(context).devices[index];
              return Container(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(device.deviceName),
                      trailing: GestureDetector(
                        // GestureDetector act as onPressed() and enables
                        // to connect/disconnect with any device
                        onTap: () => connectToDevice(device),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(8.0),
                          height: 35,
                          width: 100,
                          color: getButtonColor(device.state),
                          child: Center(
                            child: Text(
                              getButtonStateName(device.state),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        // On clicking any device tile, we navigate to the
                        // ChatPage.
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatPage(
                                converser: device.deviceName,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
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
