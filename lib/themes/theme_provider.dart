import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_data.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppThemes.lightTheme;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() async {
    _currentTheme =
    _currentTheme == AppThemes.lightTheme ? AppThemes.darkTheme : AppThemes.lightTheme;
    notifyListeners();

    // Persist theme choice
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', _currentTheme == AppThemes.darkTheme);
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _currentTheme = isDarkTheme ? AppThemes.darkTheme : AppThemes.lightTheme;
    notifyListeners();
  }
}
