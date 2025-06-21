import 'package:flutter/services.dart';

class HapticService {
  static final HapticService _instance = HapticService._internal();
  factory HapticService() => _instance;
  HapticService._internal();

  /// Light haptic feedback - for button taps, toggles
  Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback - for confirmactions
  Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback - for important actions like timer start/stop
  Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic - for UI element selection
  Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern - for notifications and alerts
  Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}
