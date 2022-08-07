import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../classes/Global.dart';

import 'ChatPage.dart';
import '../p2p/AdhocHousekeeping.dart';

enum DeviceType { advertiser, browser }

class DevicesListScreen extends StatefulWidget {
  const DevicesListScreen({required this.deviceType});

  final DeviceType deviceType;

  @override
  _DevicesListScreenState createState() => _DevicesListScreenState();
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
    return Container(
      child: SingleChildScrollView(
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
              itemCount: Provider.of<Global>(context).devices.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final device = Provider.of<Global>(context).devices[index];
                return Container(
                  margin: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(device.deviceName),
                        subtitle: Text(
                          getStateName(device.state),
                          style: TextStyle(color: getStateColor(device.state)),
                        ),
                        trailing: GestureDetector(
                          onTap: () => connectToDevice(device),
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
                        ),
                        onTap: () {
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
                      Divider(
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
      ),
    );
  }
}
