import 'package:flutter/material.dart';

class AppIcons {
  static const IconData timer = Icons.timer_outlined;
  static const IconData timerFilled = Icons.timer;
  static const IconData tasks = Icons.assignment_outlined;
  static const IconData tasksFilled = Icons.assignment;
  static const IconData statistics = Icons.analytics_outlined;
  static const IconData statisticsFilled = Icons.analytics;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData stop = Icons.stop_rounded;
  static const IconData settings = Icons.settings_outlined;
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData pomodoro = Icons.access_time_filled_rounded;
  static const IconData stopwatch = Icons.timer_outlined;
}

class AppTheme {
  // Brand colors
  static const Color primaryBlue = Color(0xFF40a9da);
  static const Color lightBlue = Color(0xFF9bd4ed);
  static const Color accentBlue = Color(0xFF8cacc1);
  static const Color lightCream = Color(0xFFfbfaf5);
  static const Color aqua = Color(0xFFcaf6fb);
  
  // Supporting colors
  static const Color primaryGreen = Color(0xFF34C759);
  static const Color primaryRed = Color(0xFFFF3B30);
  static const Color primaryOrange = Color(0xFFFF9500);
  static const Color primaryPurple = Color(0xFFAF52DE);
  
  // System grays (iOS style)
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);
  
  static ThemeData buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        primary: primaryBlue,
        secondary: lightBlue,
        tertiary: accentBlue,
        surface: lightCream,
        surfaceVariant: aqua,
        primaryContainer: lightBlue.withOpacity(0.2),
        secondaryContainer: aqua.withOpacity(0.3),
        tertiaryContainer: accentBlue.withOpacity(0.1),
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: Colors.black87,
        outline: systemGray3,
      ),
      useMaterial3: true,
      fontFamily: '.SF UI Text', // iOS system font
      scaffoldBackgroundColor: lightCream,
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: primaryBlue.withOpacity(0.1),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: Colors.white,
        surfaceTintColor: primaryBlue.withOpacity(0.02),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shadowColor: primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: primaryBlue,
          selectedBackgroundColor: primaryBlue,
          selectedForegroundColor: Colors.white,
          side: BorderSide(color: primaryBlue.withOpacity(0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: systemGray4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: systemGray4),
        ),
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: lightCream,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF UI Text',
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
        unselectedItemColor: systemGray,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
  
  static ThemeData buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryBlue,
        secondary: lightBlue,
        tertiary: accentBlue,
      ),
      useMaterial3: true,
      fontFamily: '.SF UI Text', // iOS system font
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: primaryBlue.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        surfaceTintColor: primaryBlue.withOpacity(0.05),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: BorderSide(color: primaryBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: '.SF UI Text',
        ),
      ),
    );
  }
}
