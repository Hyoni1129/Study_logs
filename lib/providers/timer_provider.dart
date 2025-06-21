import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/study_session.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';

enum TimerType { stopwatch, pomodoro }
enum TimerState { stopped, running, paused }
enum PomodoroPhase { focus, shortBreak, longBreak }

class TimerProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  final AudioService _audioService = AudioService();
  final HapticService _hapticService = HapticService();
  
  // Callback for when a session is saved (to refresh statistics)
  VoidCallback? _onSessionSaved;
  
  // Timer state
  TimerType _timerType = TimerType.stopwatch;
  TimerState _timerState = TimerState.stopped;
  int _elapsedSeconds = 0;
  int _targetSeconds = 0;
  DateTime? _startTime;
  DateTime? _pausedTime;
  Timer? _timer;
  
  // Daily time tracking
  int _todayStudyTime = 0; // Total study time for today in seconds
  DateTime _lastResetDate = DateTime.now();
  
  // Pomodoro specific
  PomodoroPhase _pomodoroPhase = PomodoroPhase.focus;
  int _pomodoroRounds = 0;
  int _focusDuration = 25 * 60; // 25 minutes in seconds
  int _shortBreakDuration = 5 * 60; // 5 minutes in seconds
  int _longBreakDuration = 15 * 60; // 15 minutes in seconds
  int _longBreakInterval = 4; // Long break after every 4 focus sessions
  
  // Selected task
  Task? _selectedTask;
  
  // Error handling
  String? _error;

  // Initialize and load today's study time
  TimerProvider() {
    _loadTodayStudyTime();
  }

  // Getters
  TimerType get timerType => _timerType;
  TimerState get timerState => _timerState;
  int get elapsedSeconds => _elapsedSeconds;
  int get targetSeconds => _targetSeconds;
  int get remainingSeconds => _targetSeconds - _elapsedSeconds;
  PomodoroPhase get pomodoroPhase => _pomodoroPhase;
  int get pomodoroRounds => _pomodoroRounds;
  Task? get selectedTask => _selectedTask;
  String? get error => _error;
  
  // Timer display getters
  bool get isRunning => _timerState == TimerState.running;
  bool get isPaused => _timerState == TimerState.paused;
  bool get isStopped => _timerState == TimerState.stopped;
  bool get canStart => _selectedTask != null && _timerState == TimerState.stopped;
  bool get canPause => _timerState == TimerState.running;
  bool get canResume => _timerState == TimerState.paused;
  bool get canStop => _timerState != TimerState.stopped;
  
  // Pomodoro getters
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  int get longBreakInterval => _longBreakInterval;
  
  // Sound settings
  bool get soundEnabled => _audioService.soundEnabled;
  
  // Progress getters
  double get progress {
    if (_targetSeconds == 0) return 0.0;
    return (_elapsedSeconds / _targetSeconds).clamp(0.0, 1.0);
  }
  
  String get formattedElapsedTime => _formatTime(_elapsedSeconds);
  String get formattedRemainingTime => _formatTime(remainingSeconds);
  String get formattedTargetTime => _formatTime(_targetSeconds);
  
  // Daily time tracking
  int get todayStudyTime => _todayStudyTime;
  String get formattedTodayTime => _formatTime(_todayStudyTime);
  
  // Check if we need to reset daily time (new day)
  void _checkDailyReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastReset = DateTime(_lastResetDate.year, _lastResetDate.month, _lastResetDate.day);
    
    if (today.isAfter(lastReset)) {
      _todayStudyTime = 0;
      _lastResetDate = now;
    }
  }

  // Load today's study time from database
  Future<void> _loadTodayStudyTime() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final timeMap = await _databaseHelper.getDailyTimePerTask(today);
      _todayStudyTime = timeMap.values.fold(0, (sum, time) => sum + time);
      _lastResetDate = now;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today\'s study time: $e');
    }
  }

  // Set timer type
  void setTimerType(TimerType type) {
    if (_timerState != TimerState.stopped) {
      _error = 'Cannot change timer type while timer is running';
      notifyListeners();
      return;
    }
    
    _timerType = type;
    _resetTimer();
    _setupTimerForType();
    notifyListeners();
  }

  // Set selected task
  void setSelectedTask(Task? task) {
    if (_timerState == TimerState.running) {
      _error = 'Cannot change task while timer is running';
      notifyListeners();
      return;
    }
    
    _selectedTask = task;
    _clearError();
    notifyListeners();
  }

  // Start timer
  Future<void> startTimer() async {
    _checkDailyReset(); // Check if we need to reset daily time
    
    if (_selectedTask == null) {
      _error = 'Please select a task before starting the timer';
      notifyListeners();
      return;
    }
    
    if (_timerState == TimerState.running) return;
    
    _timerState = TimerState.running;
    _startTime = DateTime.now();
    
    if (_pausedTime != null) {
      // Resuming from pause
      _pausedTime = null;
    } else {
      // Starting fresh - reset elapsed time and setup timer
      _elapsedSeconds = 0;
      _setupTimerForType();
    }
    
    // Play start sound and haptic feedback
    await _audioService.playStartSound();
    await _hapticService.heavyImpact();
    
    _startTick();
    _clearError();
    notifyListeners();
  }

  // Pause timer
  Future<void> pauseTimer() async {
    if (_timerState != TimerState.running) return;
    
    _timerState = TimerState.paused;
    _pausedTime = DateTime.now();
    _timer?.cancel();
    
    // Provide haptic feedback
    await _hapticService.mediumImpact();
    
    notifyListeners();
  }

  // Stop timer
  Future<void> stopTimer() async {
    if (_timerState == TimerState.stopped) return;
    
    _timer?.cancel();
    
    // Play stop sound and haptic feedback
    await _audioService.playStopSound();
    await _hapticService.heavyImpact();
    
    // Save session if there was actual time elapsed
    if (_elapsedSeconds > 0 && _selectedTask != null) {
      await _saveStudySession();
      
      // Add to daily time but don't reset the timer display immediately
      _todayStudyTime += _elapsedSeconds;
      
      // Show completion notification
      await _notificationService.showStudySessionCompleteNotification(
        taskName: _selectedTask!.name,
        duration: _formatTime(_elapsedSeconds),
      );
    }
    
    // Don't reset timer immediately - let it show the completed time
    _timer?.cancel();
    _timerState = TimerState.stopped;
    _startTime = null;
    _pausedTime = null;
    
    notifyListeners();
  }

  // Setup timer based on type
  void _setupTimerForType() {
    switch (_timerType) {
      case TimerType.stopwatch:
        _targetSeconds = 0; // Infinite for stopwatch
        // Don't reset _elapsedSeconds here - it's handled in startTimer
        break;
      case TimerType.pomodoro:
        _setupPomodoroTimer();
        break;
    }
  }

  // Setup Pomodoro timer
  void _setupPomodoroTimer() {
    switch (_pomodoroPhase) {
      case PomodoroPhase.focus:
        _targetSeconds = _focusDuration;
        break;
      case PomodoroPhase.shortBreak:
        _targetSeconds = _shortBreakDuration;
        break;
      case PomodoroPhase.longBreak:
        _targetSeconds = _longBreakDuration;
        break;
    }
    _elapsedSeconds = 0;
  }

  // Start timer tick
  void _startTick() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      
      // Check if Pomodoro timer is complete
      if (_timerType == TimerType.pomodoro && _elapsedSeconds >= _targetSeconds) {
        _handlePomodoroComplete();
      }
      
      notifyListeners();
    });
  }

  // Handle Pomodoro completion
  Future<void> _handlePomodoroComplete() async {
    _timer?.cancel();
    
    if (_pomodoroPhase == PomodoroPhase.focus) {
      // Focus session completed - save it
      if (_selectedTask != null) {
        await _saveStudySession();
      }
      
      // Play focus complete sound and show notification
      await _audioService.playFocusCompleteSound();
      await _notificationService.showPomodoroFocusCompleteNotification();
      
      // Increment rounds after focus session completion
      _pomodoroRounds++;
      
      // Determine next phase based on rounds completed
      if (_pomodoroRounds % _longBreakInterval == 0) {
        _pomodoroPhase = PomodoroPhase.longBreak;
      } else {
        _pomodoroPhase = PomodoroPhase.shortBreak;
      }
    } else {
      // Break completed - go back to focus
      await _audioService.playBreakCompleteSound();
      await _notificationService.showPomodoroBreakCompleteNotification();
      _pomodoroPhase = PomodoroPhase.focus;
    }
    
    // Reset timer state and setup for next phase
    _timerState = TimerState.stopped;
    _setupPomodoroTimer();
    _startTime = null;
    _pausedTime = null;
    
    notifyListeners();
  }

  // Save study session to database
  Future<void> _saveStudySession() async {
    if (_selectedTask == null || _startTime == null) return;
    
    try {
      final endTime = DateTime.now();
      final session = StudySession(
        taskId: _selectedTask!.id!,
        startTime: _startTime!,
        endTime: endTime,
        durationInSeconds: _elapsedSeconds,
        sessionType: _timerType == TimerType.stopwatch 
            ? SessionType.stopwatch 
            : SessionType.pomodoro,
        dateCreated: _startTime!,
      );
      
      await _databaseHelper.insertStudySession(session);
      
      // Notify statistics provider to refresh
      _onSessionSaved?.call();
    } catch (e) {
      _error = 'Failed to save study session: $e';
    }
  }

  // Reset timer to initial state
  void _resetTimer() {
    _timer?.cancel();
    _timerState = TimerState.stopped;
    _elapsedSeconds = 0;
    _targetSeconds = 0;
    _startTime = null;
    _pausedTime = null;
  }

  // Update Pomodoro durations
  void updateFocusDuration(int minutes) {
    if (_timerState != TimerState.stopped) return;
    _focusDuration = minutes * 60;
    if (_timerType == TimerType.pomodoro && _pomodoroPhase == PomodoroPhase.focus) {
      _setupPomodoroTimer();
    }
    notifyListeners();
  }

  void updateShortBreakDuration(int minutes) {
    if (_timerState != TimerState.stopped) return;
    _shortBreakDuration = minutes * 60;
    if (_timerType == TimerType.pomodoro && _pomodoroPhase == PomodoroPhase.shortBreak) {
      _setupPomodoroTimer();
    }
    notifyListeners();
  }

  void updateLongBreakDuration(int minutes) {
    if (_timerState != TimerState.stopped) return;
    _longBreakDuration = minutes * 60;
    if (_timerType == TimerType.pomodoro && _pomodoroPhase == PomodoroPhase.longBreak) {
      _setupPomodoroTimer();
    }
    notifyListeners();
  }

  void updateLongBreakInterval(int rounds) {
    _longBreakInterval = rounds;
    notifyListeners();
  }

  // Toggle sound
  void setSoundEnabled(bool enabled) {
    _audioService.setSoundEnabled(enabled);
    notifyListeners();
  }

  // Reset Pomodoro rounds
  void resetPomodoroRounds() {
    if (_timerState != TimerState.stopped) return;
    _pomodoroRounds = 0;
    _pomodoroPhase = PomodoroPhase.focus;
    _setupPomodoroTimer();
    notifyListeners();
  }

  // Callback setter for statistics refresh
  void setSessionSavedCallback(VoidCallback? callback) {
    _onSessionSaved = callback;
  }

  // Utility methods
  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // Get current phase description
  String get currentPhaseDescription {
    if (_timerType == TimerType.stopwatch) {
      return 'Stopwatch';
    }
    
    switch (_pomodoroPhase) {
      case PomodoroPhase.focus:
        return 'Focus Session';
      case PomodoroPhase.shortBreak:
        return 'Short Break';
      case PomodoroPhase.longBreak:
        return 'Long Break';
    }
  }

  // Get current phase icon
  String get currentPhaseIcon {
    if (_timerType == TimerType.stopwatch) {
      return '⏱️';
    }
    
    switch (_pomodoroPhase) {
      case PomodoroPhase.focus:
        return '🍅';
      case PomodoroPhase.shortBreak:
        return '☕';
      case PomodoroPhase.longBreak:
        return '🌟';
    }
  }

  // Get formatted time remaining for display
  String get formattedTimeRemaining {
    if (_timerType == TimerType.stopwatch) {
      return _formatTime(_elapsedSeconds);
    }
    final remaining = remainingSeconds > 0 ? remainingSeconds : 0;
    return _formatTime(remaining);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
