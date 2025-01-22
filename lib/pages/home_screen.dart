import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/profile.dart';
import 'chat_list_screen.dart';
import '../classes/global.dart';
import '../p2p/adhoc_housekeeping.dart';
import 'device_list_screen.dart';

import '../database/database_helper.dart';

/// This the home screen. This can also be considered as the
///  main screen of the application.
/// As the app launches and navigates to the HomeScreen from the Profile screen,
/// all the processes of message hopping are being initiated from this page.

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // init(context);
    refreshMessages();
  }

  /// After reading all the cache, the home screen becomes visible.
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
          title: const Text("AOSSIE"),
            centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Profile(
                      onLogin: false,
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
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
        body: const TabBarView(
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
