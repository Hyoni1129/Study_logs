class AppConstants {
  // Timer defaults
  static const int defaultFocusDurationMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultLongBreakInterval = 4;
  
  // Database
  static const String databaseName = 'studylogs.db';
  static const int databaseVersion = 1;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Validation
  static const int maxTaskNameLength = 50;
  static const int minTaskNameLength = 1;
  
  // Colors (for charts when theme colors aren't enough)
  static const List<int> chartColors = [
    0xFF1E88E5, // Blue
    0xFF43A047, // Green
    0xFFFF7043, // Orange
    0xFF8E24AA, // Purple
    0xFFE53935, // Red
    0xFF00ACC1, // Cyan
    0xFFFFB300, // Amber
    0xFF546E7A, // Blue Grey
  ];
}

class TimeUtils {
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }
  
  static String formatDurationCompact(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
  
  static String formatTimer(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
  
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
  
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }
  
  static DateTime getStartOfWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return getStartOfDay(startOfWeek);
  }
  
  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return getEndOfDay(startOfWeek.add(const Duration(days: 6)));
  }
  
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  static DateTime getEndOfMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return nextMonth.subtract(const Duration(microseconds: 1));
  }
}

class ValidationUtils {
  static String? validateTaskName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Task name is required';
    }
    
    if (value.trim().length < AppConstants.minTaskNameLength) {
      return 'Task name must be at least ${AppConstants.minTaskNameLength} character';
    }
    
    if (value.trim().length > AppConstants.maxTaskNameLength) {
      return 'Task name must be less than ${AppConstants.maxTaskNameLength} characters';
    }
    
    return null;
  }
  
  static bool isValidTaskName(String value) {
    return validateTaskName(value) == null;
  }
}
