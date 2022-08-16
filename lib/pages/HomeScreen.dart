import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/Profile.dart';
import 'ChatListScreen.dart';
import '../classes/Global.dart';
import '../p2p/AdhocHousekeeping.dart';
import 'DeviceListScreen.dart';

import '../database/DatabaseHelper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isInit = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // init(context);
    refreshMessages();
  }

  Future refreshMessages() async {
    setState(() => isLoading = true);

    readAllUpdateCache();
    setState(() => isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    readAllUpdateConversation(context);
    init(context);
  }

  @override
  void dispose() {
    Global.deviceSubscription!.cancel();
    Global.receivedDataSubscription!.cancel();
    Global.nearbyService!.stopBrowsingForPeers();
    Global.nearbyService!.stopAdvertisingPeer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: Global.scaffoldKey,
        appBar: AppBar(
          title: Text("P2P Messaging"),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(
                      onLogin: false,
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Devices",
              ),
              Tab(
                text: "All Chats",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DevicesListScreen(
              deviceType: DeviceType.browser,
            ),
            ChatListScreen(),
          ],
        ),
      ),
    );
  }
}
