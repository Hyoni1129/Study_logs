import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/task.dart';
import '../models/study_session.dart';
import '../services/database_helper.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Export data to JSON
  Future<Map<String, dynamic>> _exportDataToJson() async {
    try {
      // Get all tasks
      final tasks = await _databaseHelper.getAllTasks();
      
      // Get all study sessions
      final sessions = await _databaseHelper.getAllStudySessions();
      
      // Create backup data structure
      final backupData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'tasks': tasks.map((task) => task.toMap()).toList(),
        'sessions': sessions.map((session) => session.toMap()).toList(),
      };
      
      return backupData;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Export data to user-selected location
  Future<String?> exportData() async {
    try {
      // Get export data first
      final backupData = await _exportDataToJson();
      
      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      
      // Generate filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final filename = 'studylogs_backup_$timestamp.json';
      
      // Convert string to bytes for mobile platforms
      final bytes = utf8.encode(jsonString);
      
      // Let user choose where to save the file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup file',
        fileName: filename,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputFile == null) {
        return null; // User cancelled
      }
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to export data: $e');
    }
  }

  // Pick and import data from file
  Future<bool> importData() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return false; // User cancelled - return false to indicate no import occurred
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      
      await _importFromJsonString(jsonString);
      return true; // Successfully imported
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Import data from JSON string
  Future<void> _importFromJsonString(String jsonString) async {
    try {
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      
      // Validate backup data structure
      if (!backupData.containsKey('tasks') || !backupData.containsKey('sessions')) {
        throw Exception('Invalid backup file format');
      }

      // Clear existing data (with user confirmation in UI layer)
      await _databaseHelper.clearAllData();
      
      // Import tasks
      final tasksData = backupData['tasks'] as List;
      final tasks = tasksData.map((taskMap) => Task.fromMap(taskMap as Map<String, dynamic>)).toList();
      
      for (final task in tasks) {
        await _databaseHelper.insertTask(task);
      }
      
      // Import sessions
      final sessionsData = backupData['sessions'] as List;
      final sessions = sessionsData.map((sessionMap) => StudySession.fromMap(sessionMap as Map<String, dynamic>)).toList();
      
      for (final session in sessions) {
        await _databaseHelper.insertStudySession(session);
      }
      
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  // Get backup statistics
  Future<Map<String, int>> getBackupStats() async {
    try {
      final tasks = await _databaseHelper.getAllTasks();
      final sessions = await _databaseHelper.getAllStudySessions();
      
      return {
        'tasks': tasks.length,
        'sessions': sessions.length,
      };
    } catch (e) {
      return {'tasks': 0, 'sessions': 0};
    }
  }

  // Validate backup file without importing
  Future<Map<String, dynamic>?> validateBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final Map<String, dynamic> backupData = jsonDecode(jsonString);
      
      if (!backupData.containsKey('tasks') || !backupData.containsKey('sessions')) {
        return null;
      }
      
      final tasksCount = (backupData['tasks'] as List).length;
      final sessionsCount = (backupData['sessions'] as List).length;
      final exportDate = backupData['exportDate'] as String?;
      
      return {
        'tasksCount': tasksCount,
        'sessionsCount': sessionsCount,
        'exportDate': exportDate,
        'version': backupData['version'],
      };
    } catch (e) {
      return null;
    }
  }
}
