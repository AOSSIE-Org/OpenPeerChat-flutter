
import 'package:flutter/material.dart';
import 'pages/ChatListScreen.dart';
import 'pages/Profile.dart';
void main() {
  runApp(MyApp());
}


Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
      builder: (_) => Profile());
}

class MyApp extends StatelessWidget {
  void initState(){

  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: generateRoute,
      initialRoute: '/',
    );
  }
}


