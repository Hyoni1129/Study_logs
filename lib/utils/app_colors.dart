import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppColors {
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.primaryBlue,
      AppTheme.lightBlue,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white,
      AppTheme.lightCream,
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppTheme.lightCream,
      AppTheme.aqua,
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.accentBlue,
      AppTheme.aqua,
    ],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: AppTheme.primaryBlue.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: AppTheme.systemGray.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: AppTheme.primaryBlue.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppTheme.systemGray.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Timer colors
  static const Color focusColor = AppTheme.primaryBlue;
  static const Color breakColor = AppTheme.primaryGreen;
  static const Color longBreakColor = AppTheme.primaryPurple;
  static const Color stopwatchColor = AppTheme.primaryOrange;

  // Status colors
  static const Color successColor = AppTheme.primaryGreen;
  static const Color warningColor = AppTheme.primaryOrange;
  static const Color errorColor = AppTheme.primaryRed;
  static const Color infoColor = AppTheme.primaryBlue;

  // Chart colors
  static const List<Color> chartColors = [
    AppTheme.primaryBlue,
    AppTheme.lightBlue,
    AppTheme.accentBlue,
    AppTheme.primaryGreen,
    AppTheme.primaryOrange,
    AppTheme.primaryPurple,
    AppTheme.primaryRed,
    AppTheme.aqua,
  ];

  // Helper methods
  static Color getTaskColor(int index) {
    return chartColors[index % chartColors.length];
  }

  static Color getTimerColor(String timerType, String phase) {
    switch (timerType.toLowerCase()) {
      case 'pomodoro':
        switch (phase.toLowerCase()) {
          case 'focus':
            return focusColor;
          case 'shortbreak':
          case 'short break':
            return breakColor;
          case 'longbreak':
          case 'long break':
            return longBreakColor;
          default:
            return focusColor;
        }
      case 'stopwatch':
        return stopwatchColor;
      default:
        return AppTheme.primaryBlue;
    }
  }

  static Gradient getCardGradient({bool elevated = false}) {
    return elevated ? cardGradient : 
      LinearGradient(
        colors: [Colors.white, Colors.white.withOpacity(0.95)],
      );
  }
}
