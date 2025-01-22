import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeComponents {
  // Common border radius values
  static const double _inputBorderRadius = 12.0;
  static const double _buttonBorderRadius = 12.0;
  static const double _cardBorderRadius = 16.0;

  // Common padding values
  static const EdgeInsets _inputPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 12);

  static InputDecorationTheme inputDecorationTheme(ColorScheme colors) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceContainerHighest.withOpacity(0.5),
      contentPadding: _inputPadding,
      border: _buildInputBorder(_inputBorderRadius),
      enabledBorder: _buildInputBorder(
        _inputBorderRadius,
        borderColor: colors.outline.withOpacity(0.3),
      ),
      focusedBorder: _buildInputBorder(
        _inputBorderRadius,
        borderColor: colors.primary,
        width: 2,
      ),
      errorBorder: _buildInputBorder(
        _inputBorderRadius,
        borderColor: colors.error,
      ),
      // Add focused error border for consistency
      focusedErrorBorder: _buildInputBorder(
        _inputBorderRadius,
        borderColor: colors.error,
        width: 2,
      ),
    );
  }

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colors) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: _buttonPadding,
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
        ),
        // Add disabled colors for better accessibility
        disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
        disabledForegroundColor: colors.onSurface.withOpacity(0.38),
      ),
    );
  }

  static CardTheme cardTheme(ColorScheme colors) {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      // Add shadow color for better dark mode appearance
      shadowColor: colors.shadow,
    );
  }

  static AppBarTheme appBarTheme(ColorScheme colors) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: colors.surface,
      foregroundColor: colors.onSurface,
      iconTheme: IconThemeData(color: colors.onSurface),
      titleTextStyle: TextStyle(
        color: colors.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      // Add system overlay style for better status bar visibility
      systemOverlayStyle: colors.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  // Helper method to build input borders
  static OutlineInputBorder _buildInputBorder(
      double radius, {
        Color borderColor = Colors.transparent,
        double width = 1,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: borderColor, width: width),
    );
  }
}