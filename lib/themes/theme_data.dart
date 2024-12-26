import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
  );
}
