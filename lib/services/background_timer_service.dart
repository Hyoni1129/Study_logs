import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackgroundTimerService {
  static final BackgroundTimerService _instance = BackgroundTimerService._internal();
  factory BackgroundTimerService() => _instance;
  BackgroundTimerService._internal();

  static const MethodChannel _channel = MethodChannel('background_timer');
  
  bool _isBackgroundModeEnabled = false;
  
  /// Enable background mode for the timer
  Future<void> enableBackgroundMode() async {
    try {
      await _channel.invokeMethod('enableBackgroundMode');
      _isBackgroundModeEnabled = true;
    } on PlatformException catch (e) {
      debugPrint('Failed to enable background mode: ${e.message}');
    }
  }
  
  /// Disable background mode
  Future<void> disableBackgroundMode() async {
    try {
      await _channel.invokeMethod('disableBackgroundMode');
      _isBackgroundModeEnabled = false;
    } on PlatformException catch (e) {
      debugPrint('Failed to disable background mode: ${e.message}');
    }
  }
  
  /// Check if background mode is supported
  Future<bool> isBackgroundModeSupported() async {
    try {
      final bool supported = await _channel.invokeMethod('isBackgroundModeSupported');
      return supported;
    } on PlatformException catch (e) {
      debugPrint('Failed to check background mode support: ${e.message}');
      return false;
    }
  }
  
  /// Start background timer
  Future<void> startBackgroundTimer({
    required Duration duration,
    required String taskName,
  }) async {
    if (!_isBackgroundModeEnabled) {
      await enableBackgroundMode();
    }
    
    try {
      await _channel.invokeMethod('startBackgroundTimer', {
        'duration': duration.inSeconds,
        'taskName': taskName,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to start background timer: ${e.message}');
    }
  }
  
  /// Stop background timer
  Future<void> stopBackgroundTimer() async {
    try {
      await _channel.invokeMethod('stopBackgroundTimer');
    } on PlatformException catch (e) {
      debugPrint('Failed to stop background timer: ${e.message}');
    }
  }
  
  /// Get remaining time from background timer
  Future<int> getRemainingTime() async {
    try {
      final int remaining = await _channel.invokeMethod('getRemainingTime');
      return remaining;
    } on PlatformException catch (e) {
      debugPrint('Failed to get remaining time: ${e.message}');
      return 0;
    }
  }
  
  bool get isBackgroundModeEnabled => _isBackgroundModeEnabled;
}

/// Widget that shows a warning when the app is about to be backgrounded
class BackgroundTimerWarning extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  const BackgroundTimerWarning({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Background Timer'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your timer will continue running in the background.',
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll receive a notification when your session is complete.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

/// Mixin for handling app lifecycle changes
mixin BackgroundTimerMixin<T extends StatefulWidget> on State<T> {
  late final BackgroundTimerService _backgroundService;
  
  @override
  void initState() {
    super.initState();
    _backgroundService = BackgroundTimerService();
    WidgetsBinding.instance.addObserver(_AppLifecycleObserver(
      onAppPaused: _onAppPaused,
      onAppResumed: _onAppResumed,
    ));
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver(
      onAppPaused: _onAppPaused,
      onAppResumed: _onAppResumed,
    ));
    super.dispose();
  }
  
  void _onAppPaused() {
    onAppPaused();
  }
  
  void _onAppResumed() {
    onAppResumed();
  }
  
  /// Called when the app is paused (backgrounded)
  void onAppPaused() {}
  
  /// Called when the app is resumed (foregrounded)
  void onAppResumed() {}
}

class _AppLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onAppPaused;
  final VoidCallback onAppResumed;
  
  _AppLifecycleObserver({
    required this.onAppPaused,
    required this.onAppResumed,
  });
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        onAppPaused();
        break;
      case AppLifecycleState.resumed:
        onAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
