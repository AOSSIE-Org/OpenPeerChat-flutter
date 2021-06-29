import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'Global.dart';
import 'DeviceListScreen.dart';
import 'Msg.dart';
import 'ChatPage.dart';
import 'Profile.dart';
void main() {
  runApp(MyApp());
}


Route<dynamic> generateRoute(RouteSettings settings) {
  return MaterialPageRoute(
      builder: (_) => Profile());
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


