import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticEnabledKey = 'haptic_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode';
  static const String _pomodoroFocusKey = 'pomodoro_focus_duration';
  static const String _pomodoroShortBreakKey = 'pomodoro_short_break_duration';
  static const String _pomodoroLongBreakKey = 'pomodoro_long_break_duration';
  static const String _pomodoroLongBreakIntervalKey = 'pomodoro_long_break_interval';

  SharedPreferences? _prefs;
  bool _isLoading = false;

  // Default values
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  int _pomodoroFocusDuration = 25; // minutes
  int _pomodoroShortBreakDuration = 5; // minutes
  int _pomodoroLongBreakDuration = 15; // minutes
  int _pomodoroLongBreakInterval = 4; // sessions

  // Getters
  bool get isLoading => _isLoading;
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkMode => _darkMode;
  int get pomodoroFocusDuration => _pomodoroFocusDuration;
  int get pomodoroShortBreakDuration => _pomodoroShortBreakDuration;
  int get pomodoroLongBreakDuration => _pomodoroLongBreakDuration;
  int get pomodoroLongBreakInterval => _pomodoroLongBreakInterval;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prefs = await SharedPreferences.getInstance();
      _loadSettings();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadSettings() {
    if (_prefs == null) return;

    _soundEnabled = _prefs!.getBool(_soundEnabledKey) ?? _soundEnabled;
    _hapticEnabled = _prefs!.getBool(_hapticEnabledKey) ?? _hapticEnabled;
    _notificationsEnabled = _prefs!.getBool(_notificationsEnabledKey) ?? _notificationsEnabled;
    _darkMode = _prefs!.getBool(_darkModeKey) ?? _darkMode;
    _pomodoroFocusDuration = _prefs!.getInt(_pomodoroFocusKey) ?? _pomodoroFocusDuration;
    _pomodoroShortBreakDuration = _prefs!.getInt(_pomodoroShortBreakKey) ?? _pomodoroShortBreakDuration;
    _pomodoroLongBreakDuration = _prefs!.getInt(_pomodoroLongBreakKey) ?? _pomodoroLongBreakDuration;
    _pomodoroLongBreakInterval = _prefs!.getInt(_pomodoroLongBreakIntervalKey) ?? _pomodoroLongBreakInterval;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _prefs?.setBool(_soundEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    await _prefs?.setBool(_hapticEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs?.setBool(_notificationsEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _darkMode = enabled;
    await _prefs?.setBool(_darkModeKey, enabled);
    notifyListeners();
  }

  Future<void> setPomodoroFocusDuration(int minutes) async {
    if (minutes >= 1 && minutes <= 120) {
      _pomodoroFocusDuration = minutes;
      await _prefs?.setInt(_pomodoroFocusKey, minutes);
      notifyListeners();
    }
  }

  Future<void> setPomodoroShortBreakDuration(int minutes) async {
    if (minutes >= 1 && minutes <= 60) {
      _pomodoroShortBreakDuration = minutes;
      await _prefs?.setInt(_pomodoroShortBreakKey, minutes);
      notifyListeners();
    }
  }

  Future<void> setPomodoroLongBreakDuration(int minutes) async {
    if (minutes >= 1 && minutes <= 120) {
      _pomodoroLongBreakDuration = minutes;
      await _prefs?.setInt(_pomodoroLongBreakKey, minutes);
      notifyListeners();
    }
  }

  Future<void> setPomodoroLongBreakInterval(int sessions) async {
    if (sessions >= 2 && sessions <= 10) {
      _pomodoroLongBreakInterval = sessions;
      await _prefs?.setInt(_pomodoroLongBreakIntervalKey, sessions);
      notifyListeners();
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    await _prefs?.clear();
    _soundEnabled = true;
    _hapticEnabled = true;
    _notificationsEnabled = true;
    _darkMode = false;
    _pomodoroFocusDuration = 25;
    _pomodoroShortBreakDuration = 5;
    _pomodoroLongBreakDuration = 15;
    _pomodoroLongBreakInterval = 4;
    
    notifyListeners();
  }
}
