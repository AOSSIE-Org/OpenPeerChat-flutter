import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/theme_provider.dart';
import 'themes/theme_data.dart'; // Import AppThemes
import 'settings_page.dart'; // Import SettingsPage

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('P2P Messaging - AOSSIE'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your app\'s main content goes here.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Dark Mode'),
              value: themeProvider.currentTheme == AppThemes.darkTheme,
              onChanged: (_) => themeProvider.toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
