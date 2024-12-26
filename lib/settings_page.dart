import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/theme_provider.dart';
import 'themes/theme_data.dart'; // Import AppThemes

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access the ThemeProvider to manage theme toggling
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"), // Title for the AppBar
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text("Dark Mode"),
            trailing: Switch(
              value: themeProvider.currentTheme == AppThemes.darkTheme,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
