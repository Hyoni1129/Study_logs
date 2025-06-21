import 'package:flutter_test/flutter_test.dart';
import 'package:studylogs/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should create a task with all required fields', () {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 1,
        name: 'Study Flutter',
        createdAt: now,
        lastModified: now,
        totalTimeInSeconds: 3600, // 1 hour in seconds
      );

      // Assert
      expect(task.id, equals(1));
      expect(task.name, equals('Study Flutter'));
      expect(task.totalTimeInSeconds, equals(3600));
      expect(task.createdAt, equals(now));
      expect(task.lastModified, equals(now));
    });

    test('should create task from Map correctly', () {
      // Arrange
      final now = DateTime.now();
      final map = {
        'id': 1,
        'name': 'Study Dart',
        'created_at': now.millisecondsSinceEpoch,
        'last_modified': now.millisecondsSinceEpoch,
        'total_time_seconds': 7200,
      };

      // Act
      final task = Task.fromMap(map);

      // Assert
      expect(task.id, equals(1));
      expect(task.name, equals('Study Dart'));
      expect(task.totalTimeInSeconds, equals(7200));
      expect(task.createdAt.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
    });

    test('should convert task to Map correctly', () {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 1,
        name: 'Study Flutter',
        createdAt: now,
        lastModified: now,
        totalTimeInSeconds: 3600,
      );

      // Act
      final map = task.toMap();

      // Assert
      expect(map['id'], equals(1));
      expect(map['name'], equals('Study Flutter'));
      expect(map['total_time_seconds'], equals(3600));
      expect(map['created_at'], equals(now.millisecondsSinceEpoch));
      expect(map['last_modified'], equals(now.millisecondsSinceEpoch));
    });

    test('should format total time correctly', () {
      // Arrange & Act
      final now = DateTime.now();
      final task1 = Task(
        id: 1,
        name: 'Task 1',
        createdAt: now,
        lastModified: now,
        totalTimeInSeconds: 3661, // 1h 1m 1s
      );

      final task2 = Task(
        id: 2,
        name: 'Task 2',
        createdAt: now,
        lastModified: now,
        totalTimeInSeconds: 61, // 1m 1s
      );

      final task3 = Task(
        id: 3,
        name: 'Task 3',
        createdAt: now,
        lastModified: now,
        totalTimeInSeconds: 1, // 1s
      );

      // Assert
      expect(task1.formattedTotalTime, equals('1h 1m 1s'));
      expect(task2.formattedTotalTime, equals('1m 1s'));
      expect(task3.formattedTotalTime, equals('1s'));
    });

    test('should update total time spent correctly', () {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 1,
        name: 'Study Flutter',
        createdAt: now,
        lastModified: now,
        totalTimeInSeconds: 3600,
      );

      // Act
      final updatedTask = task.copyWith(totalTimeInSeconds: 7200);

      // Assert
      expect(updatedTask.totalTimeInSeconds, equals(7200));
      expect(updatedTask.id, equals(task.id));
      expect(updatedTask.name, equals(task.name));
    });

    test('should have default total time of 0', () {
      // Arrange & Act
      final now = DateTime.now();
      final task = Task(
        id: 1,
        name: 'New Task',
        createdAt: now,
        lastModified: now,
      );

      // Assert
      expect(task.totalTimeInSeconds, equals(0));
    });

    test('should create task with null id for new tasks', () {
      // Arrange & Act
      final now = DateTime.now();
      final task = Task(
        name: 'New Task',
        createdAt: now,
        lastModified: now,
      );

      // Assert
      expect(task.id, isNull);
      expect(task.name, equals('New Task'));
    });
  });
}
