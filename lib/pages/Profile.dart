import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/DeviceListScreen.dart';
import 'package:nanoid/nanoid.dart';
import '../classes/Global.dart';
import 'DeviceListScreen.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController myName = TextEditingController();

  var customLengthId = nanoid(6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Text("Your Username will be your name+$customLengthId"),
            TextFormField(
              controller: myName,
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'What do people call you?',
                labelText: 'Name *',
              ),
              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              validator: (String? value) {
                return (value != null && value.contains('@'))
                    ? 'Do not use the @ char.'
                    : null;
              },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                // Global.myName = myName.text+custom_length_id;
                Global.myName = myName.text;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DevicesListScreen(deviceType: DeviceType.browser),
                  ),
                );
              },
              child: Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}
