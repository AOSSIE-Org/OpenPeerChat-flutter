import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/classes/themeProvider.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/global.dart';

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

class Profile extends StatefulWidget {
  final bool onLogin;

  const Profile({Key? key, required this.onLogin}) : super(key: key);
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  //initial theme of the system
  ThemeMode _themeMode = ThemeMode.light;

  // TextEditingController for the name of the user
  TextEditingController myName = TextEditingController();

  // loading variable is used for UI purpose when the app is fetching
  // user details
  bool loading = true;

  // Custom generated id for the user
  var customLengthId = nanoid(6);

  // Fetching details from saved profile
  // If no profile is saved, then the new values are used
  // else navigate to DeviceListScreen
  Future getDetails() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('p_name') ?? '';
    final id = prefs.getString('p_id') ?? '';
    setState(() {
      myName.text = name;
      customLengthId = id.isNotEmpty ? id : customLengthId;
    });
    if (name.isNotEmpty && id.isNotEmpty && widget.onLogin) {
      navigateToHomeScreen();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  // It is a general function to navigate to home screen.
  // If we are first launching the app, we need to replace the profile page
  // from the context and then open the home screen
  // Otherwise we need to pop out the profile screen context
  // from memory of the application. This is a flutter way
  // to manage different contexts and screens.
  void navigateToHomeScreen() {
    Global.myName = myName.text;
    if (!widget.onLogin) {
      Global.myName = myName.text;
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTheme();
    // At the launch we are fetching details using the getDetails function
    getDetails();
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),
      body: Visibility(
        visible: loading,
        replacement: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: myName,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'What do people call you?',
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  return (value != null &&
                      value.contains('@') &&
                      value.length > 3)
                      ? 'Do not use the @ char and name length should be greater than 3'
                      : null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Switch to dark theme',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeColor: Colors.blueAccent,
                  inactiveThumbColor: Colors.grey,
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // saving the name and id to shared preferences
                prefs.setString('p_name', myName.text);
                prefs.setString('p_id', customLengthId);

                // On pressing, move to the home screen
                navigateToHomeScreen();
              },
              child: const Text("Save"),
            )
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}