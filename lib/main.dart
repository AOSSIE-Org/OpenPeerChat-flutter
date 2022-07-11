import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections_example/classes/Global.dart';
import 'package:provider/provider.dart';
import 'pages/Profile.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Global(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(builder: (_) => Profile());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}
