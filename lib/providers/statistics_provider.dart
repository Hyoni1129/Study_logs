import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/study_session.dart';
import '../services/database_helper.dart';

enum StatsPeriod { daily, weekly, monthly, allTime }

class TaskStatistics {
  final Task task;
  final int totalSeconds;
  final int sessionCount;
  final double percentage;

  TaskStatistics({
    required this.task,
    required this.totalSeconds,
    required this.sessionCount,
    required this.percentage,
  });

  String get formattedTime {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class StatisticsProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  // Current state
  StatsPeriod _currentPeriod = StatsPeriod.daily;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  
  // Statistics data
  List<TaskStatistics> _taskStatistics = [];
  List<StudySession> _sessions = [];
  int _totalStudyTime = 0;
  int _totalSessions = 0;
  
  // Getters
  StatsPeriod get currentPeriod => _currentPeriod;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskStatistics> get taskStatistics => _taskStatistics;
  List<StudySession> get sessions => _sessions;
  int get totalStudyTime => _totalStudyTime;
  int get totalSessions => _totalSessions;
  
  // Formatted getters
  String get formattedTotalTime {
    final hours = _totalStudyTime ~/ 3600;
    final minutes = (_totalStudyTime % 3600) ~/ 60;
    final seconds = _totalStudyTime % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  String get periodTitle {
    switch (_currentPeriod) {
      case StatsPeriod.daily:
        return _formatDate(_selectedDate, 'EEEE, MMM d');
      case StatsPeriod.weekly:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(Duration(days: 6));
        return '${_formatDate(startOfWeek, 'MMM d')} - ${_formatDate(endOfWeek, 'MMM d')}';
      case StatsPeriod.monthly:
        return _formatDate(_selectedDate, 'MMMM yyyy');
      case StatsPeriod.allTime:
        return 'All Time';
    }
  }
  
  bool get hasPreviousPeriod {
    return _currentPeriod != StatsPeriod.allTime;
  }
  
  bool get hasNextPeriod {
    if (_currentPeriod == StatsPeriod.allTime) return false;
    
    final now = DateTime.now();
    switch (_currentPeriod) {
      case StatsPeriod.daily:
        return _selectedDate.isBefore(DateTime(now.year, now.month, now.day));
      case StatsPeriod.weekly:
        final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
        final selectedWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        return selectedWeekStart.isBefore(thisWeekStart);
      case StatsPeriod.monthly:
        return _selectedDate.isBefore(DateTime(now.year, now.month));
      case StatsPeriod.allTime:
        return false;
    }
  }

  // Set period and load data
  Future<void> setPeriod(StatsPeriod period) async {
    _currentPeriod = period;
    await loadStatistics();
  }

  // Navigate to previous period
  Future<void> goToPreviousPeriod() async {
    if (!hasPreviousPeriod) return;
    
    switch (_currentPeriod) {
      case StatsPeriod.daily:
        _selectedDate = _selectedDate.subtract(Duration(days: 1));
        break;
      case StatsPeriod.weekly:
        _selectedDate = _selectedDate.subtract(Duration(days: 7));
        break;
      case StatsPeriod.monthly:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
        break;
      case StatsPeriod.allTime:
        break;
    }
    
    await loadStatistics();
  }

  // Navigate to next period
  Future<void> goToNextPeriod() async {
    if (!hasNextPeriod) return;
    
    switch (_currentPeriod) {
      case StatsPeriod.daily:
        _selectedDate = _selectedDate.add(Duration(days: 1));
        break;
      case StatsPeriod.weekly:
        _selectedDate = _selectedDate.add(Duration(days: 7));
        break;
      case StatsPeriod.monthly:
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        break;
      case StatsPeriod.allTime:
        break;
    }
    
    await loadStatistics();
  }

  // Load statistics for current period
  Future<void> loadStatistics() async {
    try {
      _setLoading(true);
      _error = null;
      
      Map<int, int> timePerTask;
      List<StudySession> sessions;
      
      switch (_currentPeriod) {
        case StatsPeriod.daily:
          timePerTask = await _databaseHelper.getDailyTimePerTask(_selectedDate);
          sessions = await _getSessionsForDay(_selectedDate);
          break;
        case StatsPeriod.weekly:
          timePerTask = await _databaseHelper.getWeeklyTimePerTask(_selectedDate);
          sessions = await _getSessionsForWeek(_selectedDate);
          break;
        case StatsPeriod.monthly:
          timePerTask = await _databaseHelper.getMonthlyTimePerTask(_selectedDate);
          sessions = await _getSessionsForMonth(_selectedDate);
          break;
        case StatsPeriod.allTime:
          timePerTask = await _databaseHelper.getTotalTimePerTask();
          sessions = await _databaseHelper.getAllStudySessions();
          break;
      }
      
      _sessions = sessions;
      _totalSessions = sessions.length;
      _totalStudyTime = timePerTask.values.fold(0, (sum, time) => sum + time);
      
      // Get all tasks to create statistics
      final allTasks = await _databaseHelper.getAllTasks();
      _taskStatistics = await _createTaskStatistics(allTasks, timePerTask);
      
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load statistics: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Create task statistics with percentages
  Future<List<TaskStatistics>> _createTaskStatistics(
    List<Task> tasks, 
    Map<int, int> timePerTask,
  ) async {
    List<TaskStatistics> statistics = [];
    
    for (Task task in tasks) {
      final totalSeconds = timePerTask[task.id] ?? 0;
      if (totalSeconds > 0) {
        final sessionCount = _sessions.where((s) => s.taskId == task.id).length;
        final percentage = _totalStudyTime > 0 ? (totalSeconds / _totalStudyTime) * 100 : 0.0;
        
        statistics.add(TaskStatistics(
          task: task,
          totalSeconds: totalSeconds,
          sessionCount: sessionCount,
          percentage: percentage,
        ));
      }
    }
    
    // Sort by total time descending
    statistics.sort((a, b) => b.totalSeconds.compareTo(a.totalSeconds));
    return statistics;
  }

  // Get sessions for a specific day
  Future<List<StudySession>> _getSessionsForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(microseconds: 1));
    return await _databaseHelper.getStudySessionsByDateRange(startOfDay, endOfDay);
  }

  // Get sessions for a specific week
  Future<List<StudySession>> _getSessionsForWeek(DateTime date) async {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(Duration(days: 7)).subtract(Duration(microseconds: 1));
    return await _databaseHelper.getStudySessionsByDateRange(startOfWeekDay, endOfWeek);
  }

  // Get sessions for a specific month
  Future<List<StudySession>> _getSessionsForMonth(DateTime date) async {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 1).subtract(Duration(microseconds: 1));
    return await _databaseHelper.getStudySessionsByDateRange(startOfMonth, endOfMonth);
  }

  // Get top tasks (limited number)
  List<TaskStatistics> getTopTasks(int limit) {
    return _taskStatistics.take(limit).toList();
  }

  // Get statistics for a specific task
  TaskStatistics? getTaskStatistics(int taskId) {
    try {
      return _taskStatistics.firstWhere((stat) => stat.task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Get average session duration
  double get averageSessionDuration {
    if (_totalSessions == 0) return 0.0;
    return _totalStudyTime / _totalSessions;
  }

  String get formattedAverageSessionDuration {
    final avgSeconds = averageSessionDuration.round();
    final minutes = avgSeconds ~/ 60;
    final seconds = avgSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  // Get most productive task
  TaskStatistics? get mostProductiveTask {
    return _taskStatistics.isNotEmpty ? _taskStatistics.first : null;
  }

  // Get daily breakdown for weekly/monthly view
  Map<DateTime, int> getDailyBreakdown() {
    Map<DateTime, int> dailyData = {};
    
    for (StudySession session in _sessions) {
      final day = DateTime(
        session.dateCreated.year,
        session.dateCreated.month,
        session.dateCreated.day,
      );
      
      dailyData[day] = (dailyData[day] ?? 0) + session.durationInSeconds;
    }
    
    return dailyData;
  }

  // Utility methods
  String _formatDate(DateTime date, String pattern) {
    // Simple date formatting - you might want to use intl package for more complex formatting
    switch (pattern) {
      case 'EEEE, MMM d':
        return '${_getDayName(date.weekday)}, ${_getMonthAbbr(date.month)} ${date.day}';
      case 'MMM d':
        return '${_getMonthAbbr(date.month)} ${date.day}';
      case 'MMMM yyyy':
        return '${_getMonthName(date.month)} ${date.year}';
      default:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  String _getMonthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Initialize provider
  Future<void> initialize() async {
    await loadStatistics();
  }

  // Refresh current statistics
  Future<void> refresh() async {
    await loadStatistics();
  }
}
