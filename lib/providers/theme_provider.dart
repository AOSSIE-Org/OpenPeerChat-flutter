import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_colors.dart';
import 'theme_components.dart';

class ThemeProvider with ChangeNotifier {
  static const String baseThemeKey = 'base_theme';
  static const String colorSchemeKey = 'color_scheme';

  // Base themes (Light/Dark)
  static final Map<String, ThemeData> baseThemes = {
    'Light': buildTheme(ThemeColors.lightColorScheme),
    'Dark': buildTheme(ThemeColors.darkColorScheme),
  };

  // Color schemes that can be applied to either base theme
  static final Map<String, ColorScheme> colorSchemes = {
    'Default': ThemeColors.lightColorScheme,
    'Neon': ThemeColors.neonColorScheme,
    'Amber': ThemeColors.amberColorScheme,
    'Bubblegum': ThemeColors.bubblegumColorScheme,
    'Lavender': ThemeColors.lavenderColorScheme,
    'Rose': ThemeColors.roseColorScheme,
    'Nature': ThemeColors.natureColorScheme,
  };



  String _baseTheme = 'Light';
  String _colorScheme = 'Default';

  ThemeProvider() {
    loadTheme();
  }

  String get baseTheme => _baseTheme;
  String get colorSchemeName => _colorScheme;

  // Get the current theme data
  // Get the current theme data
  ThemeData get theme {
    if (_colorScheme == 'Default') {
      // Use base theme directly
      return baseThemes[_baseTheme]!;
    } else {
      // Get the appropriate color scheme based on base theme
      ColorScheme customScheme = _baseTheme == 'Dark'
          ? getDarkScheme(_colorScheme)
          : colorSchemes[_colorScheme]!;

      return buildTheme(customScheme);
    }
  }



  static ThemeData buildTheme(ColorScheme colorScheme) {
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

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _baseTheme = prefs.getString(baseThemeKey) ?? 'Light';
    _colorScheme = prefs.getString(colorSchemeKey) ?? 'Default';
    notifyListeners();
  }

  Future<void> setBaseTheme(String themeName) async {
    if (!baseThemes.containsKey(themeName)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(baseThemeKey, themeName);
    _baseTheme = themeName;
    notifyListeners();
  }

  Future<void> setColorScheme(String schemeName) async {
    if (!colorSchemes.containsKey(schemeName)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(colorSchemeKey, schemeName);
    _colorScheme = schemeName;
    notifyListeners();
  }
  static ColorScheme getDarkScheme(String name) {
    switch (name) {
      case 'Nature':
        return ThemeColors.natureDarkColorScheme;
      case 'Amber':
        return ThemeColors.amberDarkColorScheme;
      case 'Rose':
        return ThemeColors.roseDarkColorScheme;
      case 'Bubblegum':
        return ThemeColors.bubblegumDarkColorScheme;
      case 'Lavender':
        return ThemeColors.lavenderDarkColorScheme;
      case 'Neon':
        return ThemeColors.neonDarkColorScheme;
      default:
        return ThemeColors.darkColorScheme;
    }
  }

}