import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/profile.dart';
import 'chat_list_screen.dart';
import '../classes/global.dart';
import '../p2p/adhoc_housekeeping.dart';
import 'device_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';

/// This the home screen. This can also be considered as the
/// main screen of the application.
/// As the app launches and navigates to the HomeScreen from the Profile screen,
/// all the processes of message hopping are being initiated from this page.

const String themePreferenceKey = 'themePreference';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.black87,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  hintColor: Colors.blueAccent,
  scaffoldBackgroundColor: Colors.grey[850],
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(
      fontSize: 16.0,
      color: Colors.white70,
    ),
  ),
);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = false;

  //initial theme of the system
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    refreshMessages();
    _loadTheme();
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

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? themeIndex = prefs.getInt(themePreferenceKey);
    if (themeIndex != null) {
      setState(() {
        _themeMode = ThemeMode.values[themeIndex];
      });
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themePreferenceKey, mode.index);
  }

  void _toggleTheme(bool value) {
    setState(() {
      _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    });
    _saveTheme(_themeMode);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Theme(
        data: ThemeData(
          brightness: _themeMode == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light,
        ),
        child: Scaffold(
          key: Global.scaffoldKey,
          appBar: AppBar(
            title: const Text("AOSSIE"),
            actions: [
              // Slider toggle button for light and dark themes
              Switch(
                value: _themeMode == ThemeMode.dark,
                onChanged: _toggleTheme,
                activeColor: Colors.blueAccent,
                inactiveThumbColor: Colors.grey,
              ),
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
      ),
    );
  }
}
