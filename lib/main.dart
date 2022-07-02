import 'package:flutter/material.dart';
import 'pages/Profile.dart';

void main() {
  runApp(
    MyApp(),
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
