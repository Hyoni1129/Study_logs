import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';
import '../models/study_session.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'studylogs.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        last_modified INTEGER NOT NULL,
        total_time_seconds INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create study_sessions table
    await db.execute('''
      CREATE TABLE study_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        session_type INTEGER NOT NULL,
        date_created INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_sessions_task_id ON study_sessions(task_id)');
    await db.execute('CREATE INDEX idx_sessions_date_created ON study_sessions(date_created)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    // This will be used for future app updates
  }

  // ========== TASK OPERATIONS ==========

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    // This will also delete all associated study sessions due to CASCADE
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTaskTotalTime(int taskId, int additionalSeconds) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE tasks 
      SET total_time_seconds = total_time_seconds + ?, 
          last_modified = ?
      WHERE id = ?
    ''', [additionalSeconds, DateTime.now().millisecondsSinceEpoch, taskId]);
  }

  // ========== STUDY SESSION OPERATIONS ==========

  Future<int> insertStudySession(StudySession session) async {
    final db = await database;
    final sessionId = await db.insert('study_sessions', session.toMap());
    
    // Update task total time
    await updateTaskTotalTime(session.taskId, session.durationInSeconds);
    
    return sessionId;
  }

  Future<List<StudySession>> getAllStudySessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      orderBy: 'date_created DESC',
    );

    return List.generate(maps.length, (i) {
      return StudySession.fromMap(maps[i]);
    });
  }

  Future<List<StudySession>> getStudySessionsForTask(int taskId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      where: 'task_id = ?',
      whereArgs: [taskId],
      orderBy: 'date_created DESC',
    );

    return List.generate(maps.length, (i) {
      return StudySession.fromMap(maps[i]);
    });
  }

  Future<List<StudySession>> getStudySessionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      where: 'date_created >= ? AND date_created <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'date_created DESC',
    );

    return List.generate(maps.length, (i) {
      return StudySession.fromMap(maps[i]);
    });
  }

  Future<int> deleteStudySession(int id) async {
    final db = await database;
    
    // Get the session first to update task total time
    final session = await getStudySession(id);
    if (session != null) {
      await updateTaskTotalTime(session.taskId, -session.durationInSeconds);
    }
    
    return await db.delete(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<StudySession?> getStudySession(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return StudySession.fromMap(maps.first);
    }
    return null;
  }

  // ========== STATISTICS OPERATIONS ==========

  Future<Map<int, int>> getTotalTimePerTask() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT task_id, SUM(duration_seconds) as total_time
      FROM study_sessions
      GROUP BY task_id
    ''');

    Map<int, int> timePerTask = {};
    for (var row in result) {
      timePerTask[row['task_id']] = row['total_time'];
    }
    return timePerTask;
  }

  Future<Map<int, int>> getDailyTimePerTask(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1)).subtract(Duration(microseconds: 1));
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT task_id, SUM(duration_seconds) as total_time
      FROM study_sessions
      WHERE date_created >= ? AND date_created <= ?
      GROUP BY task_id
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

    Map<int, int> timePerTask = {};
    for (var row in result) {
      timePerTask[row['task_id']] = row['total_time'];
    }
    return timePerTask;
  }

  Future<Map<int, int>> getWeeklyTimePerTask(DateTime date) async {
    final db = await database;
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(Duration(days: 7)).subtract(Duration(microseconds: 1));
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT task_id, SUM(duration_seconds) as total_time
      FROM study_sessions
      WHERE date_created >= ? AND date_created <= ?
      GROUP BY task_id
    ''', [startOfWeekDay.millisecondsSinceEpoch, endOfWeek.millisecondsSinceEpoch]);

    Map<int, int> timePerTask = {};
    for (var row in result) {
      timePerTask[row['task_id']] = row['total_time'];
    }
    return timePerTask;
  }

  Future<Map<int, int>> getMonthlyTimePerTask(DateTime date) async {
    final db = await database;
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 1).subtract(Duration(microseconds: 1));
    
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT task_id, SUM(duration_seconds) as total_time
      FROM study_sessions
      WHERE date_created >= ? AND date_created <= ?
      GROUP BY task_id
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    Map<int, int> timePerTask = {};
    for (var row in result) {
      timePerTask[row['task_id']] = row['total_time'];
    }
    return timePerTask;
  }

  // ========== UTILITY OPERATIONS ==========

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('study_sessions');
    await db.delete('tasks');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
