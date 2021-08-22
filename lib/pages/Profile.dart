import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/pages/ChatListScreen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_nearby_connections_example/p2p/MatrixServerModel.dart';
import 'package:nanoid/nanoid.dart';
import '../classes/Global.dart';

class Profile extends StatelessWidget {
  TextEditingController myName = TextEditingController();
  TextEditingController serverUrl = TextEditingController();
  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  var custom_length_id = nanoid(6);
  @override
  Widget build(BuildContext context) {
    var server = context.watch<MatrixServer>();
    print('server ${server.toString()}');
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            Text("Your Username will be your name+$custom_length_id"),
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
            TextFormField(
              controller: serverUrl,
              decoration: const InputDecoration(
                icon: Icon(Icons.circle_rounded),
                hintText: 'Server you wish to connect to',
                labelText: 'Server Url *',
              ),
              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              // validator: (String? value) {
              //   return (value != null && value.contains('@'))
              //       ? 'Do not use the @ char.'
              //       : null;
              // },
            ),
            TextFormField(
              controller: userName,
              decoration: const InputDecoration(
                icon: Icon(Icons.person_add),
                hintText: 'Enter you matrix username?',
                labelText: 'Username *',
              ),
              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              // validator: (String? value) {
              //   return (value != null && value.contains('@'))
              //       ? 'Do not use the @ char.'
              //       : null;
              // },
            ),
            TextFormField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                icon: Icon(Icons.password),
                hintText: 'Enter you matrix password?',
                labelText: 'Password *',
              ),
              onSaved: (String? value) {
                // This optional block of code can be used to run
                // code when the user saves the form.
              },
              // validator: (String? value) {
              //   return (value != null && value.contains('@'))
              //       ? 'Do not use the @ char.'
              //       : null;
              // },
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                // Global.myName = myName.text+custom_length_id;
                await server.setServerConfig(
                    serverUrl.text, myName.text, userName.text, password.text);
                Global.myName = myName.text;
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatListScreen(),
                    // DevicesListScreen(deviceType: DeviceType.browser),
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
