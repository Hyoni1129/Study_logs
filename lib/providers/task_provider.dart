import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<Task> _tasks = [];
  Task? _selectedTask;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  Task? get selectedTask => _selectedTask;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasTasks => _tasks.isNotEmpty;

  // Load all tasks from database
  Future<void> loadTasks() async {
    try {
      _setLoading(true);
      _error = null;
      _tasks = await _databaseHelper.getAllTasksWithTotalTimes();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tasks: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Add a new task
  Future<bool> addTask(String taskName) async {
    try {
      _setLoading(true);
      _error = null;
      
      // Check if task name already exists
      if (_tasks.any((task) => task.name.toLowerCase() == taskName.toLowerCase())) {
        _error = 'Task with this name already exists';
        notifyListeners();
        return false;
      }

      final now = DateTime.now();
      final newTask = Task(
        name: taskName.trim(),
        createdAt: now,
        lastModified: now,
      );

      final taskId = await _databaseHelper.insertTask(newTask);
      final insertedTask = newTask.copyWith(id: taskId);
      
      _tasks.add(insertedTask);
      _tasks.sort((a, b) => a.name.compareTo(b.name));
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add task: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update an existing task
  Future<bool> updateTask(int taskId, String newTaskName) async {
    try {
      _setLoading(true);
      _error = null;
      
      // Check if task name already exists (excluding current task)
      if (_tasks.any((task) => 
          task.id != taskId && 
          task.name.toLowerCase() == newTaskName.toLowerCase())) {
        _error = 'Task with this name already exists';
        notifyListeners();
        return false;
      }

      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        _error = 'Task not found';
        notifyListeners();
        return false;
      }

      final updatedTask = _tasks[taskIndex].copyWith(
        name: newTaskName.trim(),
        lastModified: DateTime.now(),
      );

      await _databaseHelper.updateTask(updatedTask);
      _tasks[taskIndex] = updatedTask;
      _tasks.sort((a, b) => a.name.compareTo(b.name));
      
      // Update selected task if it was the updated one
      if (_selectedTask?.id == taskId) {
        _selectedTask = updatedTask;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update task: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete a task
  Future<bool> deleteTask(int taskId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _databaseHelper.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      
      // Clear selected task if it was deleted
      if (_selectedTask?.id == taskId) {
        _selectedTask = null;
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete task: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select a task for timing
  void selectTask(Task? task) {
    _selectedTask = task;
    notifyListeners();
  }

  // Get task by ID
  Task? getTaskById(int taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  // Update task total time (called after study session)
  void updateTaskTotalTime(int taskId, int additionalSeconds) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        totalTimeInSeconds: _tasks[taskIndex].totalTimeInSeconds + additionalSeconds,
        lastModified: DateTime.now(),
      );
      
      // Update selected task if it matches
      if (_selectedTask?.id == taskId) {
        _selectedTask = _tasks[taskIndex];
      }
      
      notifyListeners();
    }
  }
  
  // Refresh tasks from database (to get updated total times)
  Future<void> refreshTasks() async {
    try {
      final refreshedTasks = await _databaseHelper.getAllTasksWithTotalTimes();
      _tasks = refreshedTasks;
      _tasks.sort((a, b) => a.name.compareTo(b.name));
      
      // Update selected task if it exists
      if (_selectedTask != null) {
        final updatedSelectedTask = _tasks.firstWhere(
          (task) => task.id == _selectedTask!.id,
          orElse: () => _selectedTask!,
        );
        _selectedTask = updatedSelectedTask;
      }
      
      notifyListeners();
    } catch (e) {
      // Silently handle refresh errors
      debugPrint('Failed to refresh tasks: $e');
    }
  }

  // Get tasks sorted by total time (for statistics)
  List<Task> get tasksSortedByTime {
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) => b.totalTimeInSeconds.compareTo(a.totalTimeInSeconds));
    return sortedTasks;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      notifyListeners();
    }
  }

  // Initialize provider (call this when app starts)
  Future<void> initialize() async {
    await loadTasks();
  }
}
