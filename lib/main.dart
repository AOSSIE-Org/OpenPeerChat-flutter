/// The logic for the Adhoc and the UI are separated.
/// The different section are listed as follows
/// - p2p => Backend of application where message protocols, connections, state are managed
/// - pages => This is the UI section of the application
/// - encryption => The messages are encrypted here.
/// - database => Storage for our messages and conversations
/// - classes => Different model classes for databases
/// - components => Common UI components

import 'package:flutter/material.dart';
import 'classes/Global.dart';
import 'package:provider/provider.dart';
import 'pages/Profile.dart';

void main() {
  runApp(
    // Provider is used for state management. The state management will help us
    // to know when a new message has arrived and to refresh the chat page.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // Currently we have single class for to manage which contains the
          // required data and streams
          create: (_) => Global(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

Route<dynamic> generateRoute(RouteSettings settings) {
  // Initially app opens the profile page where we need to either create
  // new profile or
  // navigate to the home screen
  return MaterialPageRoute(
    builder: (_) => Profile(
      onLogin: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}
