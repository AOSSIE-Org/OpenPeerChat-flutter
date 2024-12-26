import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/theme_provider.dart';
import 'home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(), // Provide ThemeProvider for theme management
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme, // Dynamically set the theme
      home: HomeScreen(), // Home screen of the app
    );
  }
}
