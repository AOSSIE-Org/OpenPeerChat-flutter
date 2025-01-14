import 'package:flutter/material.dart';

class ThemeColors {
  // Extended color properties for all schemes

  // Light Theme Colors
  static final lightColorScheme = ColorScheme.light(
    primary: const Color(0xFF0061A4),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFD1E4FF),
    onPrimaryContainer: const Color(0xFF001D36),
    secondary: const Color(0xFF535F70),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFD7E3F7),
    onSecondaryContainer: const Color(0xFF101C2B),
    surface: const Color(0xFFFBFCFF),
    onSurface: const Color(0xFF1A1C1E),
    surfaceContainerHighest: const Color(0xFFDFE2EB),
    onSurfaceVariant: const Color(0xFF43474E),
    // Add error colors for form validation
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    // Add shadow color for elevation
    shadow: Colors.black.withOpacity(0.1),
  );

  // Dark Theme Colors
  static final darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF9ECAFF),
    onPrimary: const Color(0xFF003258),
    primaryContainer: const Color(0xFF00497D),
    onPrimaryContainer: const Color(0xFFD1E4FF),
    secondary: const Color(0xFFBBC7DB),
    onSecondary: const Color(0xFF253140),
    secondaryContainer: const Color(0xFF3B4858),
    onSecondaryContainer: const Color(0xFFD7E3F7),
    surface: const Color(0xFF1A1C1E),
    onSurface: const Color(0xFFE2E2E6),
    surfaceContainerHighest: const Color(0xFF43474E),
    onSurfaceVariant: const Color(0xFFC3C7CF),
    // Add error colors for form validation
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    // Add shadow color for elevation
    shadow: Colors.black.withOpacity(0.3),
  );

  // Nature Theme Colors
  static final natureColorScheme = ColorScheme.light(
  primary: const Color(0xFF246C2C),
  onPrimary: const Color(0xFFFFFFFF),
  primaryContainer: const Color(0xFFA8F5A4),
  onPrimaryContainer: const Color(0xFF002204),
  secondary: const Color(0xFF52634F),
  onSecondary: const Color(0xFFFFFFFF),
  secondaryContainer: const Color(0xFFD5E8CF),
  onSecondaryContainer: const Color(0xFF101F0F),
  surface: const Color(0xFFFBFDF7),
  onSurface: const Color(0xFF1A1C19),
  surfaceContainerHighest: const Color(0xFFDEE5D9),
  onSurfaceVariant: const Color(0xFF424940),
  error: const Color(0xFFBA1A1A),
  onError: const Color(0xFFFFFFFF),
  errorContainer: const Color(0xFFFFDAD6),
  onErrorContainer: const Color(0xFF410002),
  shadow: Colors.black.withOpacity(0.1),
  );

  static final natureDarkColorScheme = ColorScheme.dark(
  primary: const Color(0xFF8CD889),
  onPrimary: const Color(0xFF003909),
  primaryContainer: const Color(0xFF165219),
  onPrimaryContainer: const Color(0xFFA8F5A4),
  secondary: const Color(0xFFB9CCB4),
  onSecondary: const Color(0xFF263423),
  secondaryContainer: const Color(0xFF3C4B38),
  onSecondaryContainer: const Color(0xFFD5E8CF),
  surface: const Color(0xFF1A1C19),
  onSurface: const Color(0xFFE2E3DE),
  surfaceContainerHighest: const Color(0xFF424940),
  onSurfaceVariant: const Color(0xFFC2C9BE),
  error: const Color(0xFFFFB4AB),
  onError: const Color(0xFF690005),
  errorContainer: const Color(0xFF93000A),
  onErrorContainer: const Color(0xFFFFDAD6),
  shadow: Colors.black.withOpacity(0.3),
  );

  // Amber Theme Colors
  static final amberColorScheme = ColorScheme.light(
    primary: const Color(0xFFFFA726),
    onPrimary: const Color(0xFF000000),
    primaryContainer: const Color(0xFFFFECB3),
    onPrimaryContainer: const Color(0xFF261900),
    secondary: const Color(0xFFFFB74D),
    onSecondary: const Color(0xFF000000),
    secondaryContainer: const Color(0xFFFFF3E0),
    onSecondaryContainer: const Color(0xFF261900),
    surface: const Color(0xFFFFFBF5),
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFFFFEFD5),
    onSurfaceVariant: const Color(0xFF4E4B40),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    shadow: Colors.black.withOpacity(0.1),
  );

  static final amberDarkColorScheme = ColorScheme.dark(
    primary: const Color(0xFFFFD180),
    onPrimary: const Color(0xFF2B1700),
    primaryContainer: const Color(0xFFFF9800),
    onPrimaryContainer: const Color(0xFFFFECCC),
    secondary: const Color(0xFFFFE0B2),
    onSecondary: const Color(0xFF261500),
    secondaryContainer: const Color(0xFFE65100),
    onSecondaryContainer: const Color(0xFFFFF4E6),
    surface: const Color(0xFF121212),
    onSurface: const Color(0xFFFAFAFA),
    surfaceContainerHighest: const Color(0xFF3D3833),
    onSurfaceVariant: const Color(0xFFE8DED2),
    error: const Color(0xFFFF8A80),
    onError: const Color(0xFF480000),
    errorContainer: const Color(0xFFB71C1C),
    onErrorContainer: const Color(0xFFFFEBEE),
    shadow: Colors.black.withOpacity(0.4),
  );



  // Rose Theme Colors
  static final roseColorScheme = ColorScheme.light(
    primary: const Color(0xFFE84A5F),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFFFE4E8),
    onPrimaryContainer: const Color(0xFF400012),
    secondary: const Color(0xFF9D8189),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFFFD8E4),
    onSecondaryContainer: const Color(0xFF2E1519),
    surface: const Color(0xFFFFF5F7),
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFFFFECF1),
    onSurfaceVariant: const Color(0xFF534346),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    shadow: Colors.black.withOpacity(0.1),
  );

  static final roseDarkColorScheme = ColorScheme.dark(
    primary: const Color(0xFFFF8FA3),
    onPrimary: const Color(0xFF4A0012),
    primaryContainer: const Color(0xFFB4364A),
    onPrimaryContainer: const Color(0xFFFFE4E8),
    secondary: const Color(0xFFD1A0AA),
    onSecondary: const Color(0xFF2B1419),
    secondaryContainer: const Color(0xFF432931),
    onSecondaryContainer: const Color(0xFFFFD8E4),
    surface: const Color(0xFF151111),
    onSurface: const Color(0xFFE8E0E1),
    surfaceContainerHighest: const Color(0xFF3D2F32),
    onSurfaceVariant: const Color(0xFFD6C2C7),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    shadow: Colors.black.withOpacity(0.3),
  );


  // Bubblegum Theme Colors
  static final bubblegumColorScheme = ColorScheme.light(
  primary: const Color(0xFFFF69B4),
  onPrimary: const Color(0xFFFFFFFF),
  primaryContainer: const Color(0xFFFFD6E9),
  onPrimaryContainer: const Color(0xFF3F0020),
  secondary: const Color(0xFFFF9ECD),
  onSecondary: const Color(0xFF000000),
  secondaryContainer: const Color(0xFFFFE3F1),
  onSecondaryContainer: const Color(0xFF3F002D),
  surface: const Color(0xFFFFF5F9),
  onSurface: const Color(0xFF1A1A1A),
  surfaceContainerHighest: const Color(0xFFFFE6F3),
  onSurfaceVariant: const Color(0xFF534347),
  error: const Color(0xFFBA1A1A),
  onError: const Color(0xFFFFFFFF),
  errorContainer: const Color(0xFFFFDAD6),
  onErrorContainer: const Color(0xFF410002),
  shadow: Colors.black.withOpacity(0.1),
  );

  static final bubblegumDarkColorScheme = ColorScheme.dark(
    primary: const Color(0xFFFF80CE),
    onPrimary: const Color(0xFF3B0026),
    primaryContainer: const Color(0xFFD4458B),
    onPrimaryContainer: const Color(0xFFFFD6E9),
    secondary: const Color(0xFFFF9ED2),
    onSecondary: const Color(0xFF330024),
    secondaryContainer: const Color(0xFF8B2E63),
    onSecondaryContainer: const Color(0xFFFFE3F1),
    surface: const Color(0xFF120D0F),
    onSurface: const Color(0xFFE8E0E4),
    surfaceContainerHighest: const Color(0xFF3D2934),
    onSurfaceVariant: const Color(0xFFD6C2C8),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    shadow: Colors.black.withOpacity(0.3),
  );

  // Lavender Theme
  static final lavenderColorScheme = ColorScheme.light(
    primary: const Color(0xFF9575CD),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFEDE7F6),
    onPrimaryContainer: const Color(0xFF1B0057),
    secondary: const Color(0xFFB39DDB),
    onSecondary: const Color(0xFF000000),
    secondaryContainer: const Color(0xFFF3E5F5),
    onSecondaryContainer: const Color(0xFF2A0049),
    surface: const Color(0xFFFCF8FF),
    onSurface: const Color(0xFF1A191C),
    surfaceContainerHighest: const Color(0xFFE8E0F0),
    onSurfaceVariant: const Color(0xFF49454E),
    error: const Color(0xFFBA1A1A),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFDAD6),
    onErrorContainer: const Color(0xFF410002),
    shadow: Colors.black.withOpacity(0.1),
  );

  static final lavenderDarkColorScheme = ColorScheme.dark(
    primary: const Color(0xFFB39DDB),
    onPrimary: const Color(0xFF2A004C),
    primaryContainer: const Color(0xFF6A3AA7),
    onPrimaryContainer: const Color(0xFFEDE7F6),
    secondary: const Color(0xFFD1C4E9),
    onSecondary: const Color(0xFF1D0033),
    secondaryContainer: const Color(0xFF4527A0),
    onSecondaryContainer: const Color(0xFFF3E5F5),
    surface: const Color(0xFF120F17),
    onSurface: const Color(0xFFE6E1E6),
    surfaceContainerHighest: const Color(0xFF332D3F),
    onSurfaceVariant: const Color(0xFFCBC4CE),
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    errorContainer: const Color(0xFF93000A),
    onErrorContainer: const Color(0xFFFFDAD6),
    shadow: Colors.black.withOpacity(0.3),
  );

// Neon Theme
  static final neonColorScheme = ColorScheme.light(
    primary: const Color(0xFF00CC7D),
    onPrimary: const Color(0xFF000000),
    primaryContainer: const Color(0xFF80FFB9),
    onPrimaryContainer: const Color(0xFF002117),
    secondary: const Color(0xFF00B8C4),
    onSecondary: const Color(0xFF000000),
    secondaryContainer: const Color(0xFF80F4FF),
    onSecondaryContainer: const Color(0xFF002022),
    surface: const Color(0xFFECF4F2),
    onSurface: const Color(0xFF121212),
    surfaceContainerHighest: const Color(0xFFD8E8E4),
    onSurfaceVariant: const Color(0xFF1F2625),
    error: const Color(0xFFE60052),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFFB3CB),
    onErrorContainer: const Color(0xFF400016),
    shadow: Colors.black.withOpacity(0.2),
  );



  static final neonDarkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF00FF9C),
    onPrimary: const Color(0xFF001A12),
    primaryContainer: const Color(0xFF00995D),
    onPrimaryContainer: const Color(0xFFB3FFD6),
    secondary: const Color(0xFF00F3FF),
    onSecondary: const Color(0xFF001618),
    secondaryContainer: const Color(0xFF009199),
    onSecondaryContainer: const Color(0xFFB3FCFF),
    surface: const Color(0xFF050505),
    onSurface: const Color(0xFFE0E0E0),
    surfaceContainerHighest: const Color(0xFF1A1A1A),
    onSurfaceVariant: const Color(0xFFCACACA),
    error: const Color(0xFFFF0059),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFF99003D),
    onErrorContainer: const Color(0xFFFFB3CB),
    shadow: Colors.black.withOpacity(0.4),
  );

}
