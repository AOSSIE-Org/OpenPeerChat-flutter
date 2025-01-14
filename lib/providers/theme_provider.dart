import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_colors.dart';
import 'theme_components.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themePreferenceKey = 'selected_theme';

  static final Map<String, ThemeData> availableThemes = {
    'Light': _buildTheme(ThemeColors.lightColorScheme),
    'Dark': _buildTheme(ThemeColors.darkColorScheme),
    'Nature': _buildTheme(ThemeColors.natureColorScheme),
  };

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,

      // Component Themes
      inputDecorationTheme: ThemeComponents.inputDecorationTheme(colorScheme),
      elevatedButtonTheme: ThemeComponents.elevatedButtonTheme(colorScheme),
      cardTheme: ThemeComponents.cardTheme(colorScheme),
      appBarTheme: ThemeComponents.appBarTheme(colorScheme),

      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        elevation: 3,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        backgroundColor: colorScheme.surface,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tileColor: colorScheme.surface,
        iconColor: colorScheme.primary,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

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
