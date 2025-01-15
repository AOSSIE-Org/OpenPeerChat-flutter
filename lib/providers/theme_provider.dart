
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'selected_theme';

  // Define available themes
  static final Map<String, ThemeData> availableThemes = {
    'Light': ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      colorScheme: ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
      ),
    ),
    'Dark': ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueGrey[900],
      colorScheme: ColorScheme.dark(
        primary: Colors.blueGrey[900]!,
        secondary: Colors.blueAccent,
      ),
    ),
    'Nature': ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.green,
      colorScheme: ColorScheme.light(
        primary: Colors.green,
        secondary: Colors.lightGreen,
      ),
    ),
    'Ocean': ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.cyan,
      colorScheme: ColorScheme.light(
        primary: Colors.cyan,
        secondary: Colors.lightBlue,
      ),
    ),
    'Sunset': ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.orange,
      colorScheme: ColorScheme.light(
        primary: Colors.orange,
        secondary: Colors.deepOrange,
      ),
    ),
  };

  String _currentTheme = 'Light';

  ThemeProvider() {
    loadTheme();
  }

  String get currentTheme => _currentTheme;
  ThemeData get theme => availableThemes[_currentTheme]!;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _currentTheme = prefs.getString(_themePreferenceKey) ?? 'Light';
    notifyListeners();
  }

  Future<void> setTheme(String themeName) async {
    if (!availableThemes.containsKey(themeName)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, themeName);

    _currentTheme = themeName;
    notifyListeners();
  }
}