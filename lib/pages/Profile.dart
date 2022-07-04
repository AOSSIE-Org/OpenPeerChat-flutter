import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/DeviceListScreen.dart';
import 'package:nanoid/nanoid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/Global.dart';
import 'DeviceListScreen.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // TextEditingController for the name of the user
  TextEditingController myName = TextEditingController();
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
    });
    if (name.isNotEmpty && id.isNotEmpty) {
      navigateToDeviceListScreen();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  void navigateToDeviceListScreen() {
    Global.myName = myName.text;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DevicesListScreen(
          deviceType: DeviceType.browser,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
        ),
      ),
      body: Visibility(
        visible: loading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Your Username will be your name+$customLengthId"),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // saving the name and id to shared preferences
                prefs.setString('p_name', myName.text);
                prefs.setString('p_id', customLengthId);
                // On pressing, move to the device list screen
                navigateToDeviceListScreen();
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
