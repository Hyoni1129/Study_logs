import 'package:flutter_test/flutter_test.dart';
import 'package:studylogs/models/study_session.dart';

void main() {
  group('StudySession Model Tests', () {
    test('should create a study session with all required fields', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(hours: 1));
      final dateCreated = DateTime.now();
      
      final session = StudySession(
        id: 1,
        taskId: 1,
        startTime: startTime,
        endTime: endTime,
        durationInSeconds: 3600,
        sessionType: SessionType.stopwatch,
        dateCreated: dateCreated,
      );

      // Assert
      expect(session.id, equals(1));
      expect(session.taskId, equals(1));
      expect(session.startTime, equals(startTime));
      expect(session.endTime, equals(endTime));
      expect(session.durationInSeconds, equals(3600));
      expect(session.sessionType, equals(SessionType.stopwatch));
      expect(session.dateCreated, equals(dateCreated));
    });

    test('should create session from Map correctly', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 30));
      final dateCreated = DateTime.now();
      
      final map = {
        'id': 1,
        'task_id': 2,
        'start_time': startTime.millisecondsSinceEpoch,
        'end_time': endTime.millisecondsSinceEpoch,
        'duration_seconds': 1800,
        'session_type': 1, // pomodoro index
        'date_created': dateCreated.millisecondsSinceEpoch,
      };

      // Act
      final session = StudySession.fromMap(map);

      // Assert
      expect(session.id, equals(1));
      expect(session.taskId, equals(2));
      expect(session.durationInSeconds, equals(1800));
      expect(session.sessionType, equals(SessionType.pomodoro));
    });

    test('should convert session to Map correctly', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 25));
      final dateCreated = DateTime.now();
      
      final session = StudySession(
        id: 1,
        taskId: 3,
        startTime: startTime,
        endTime: endTime,
        durationInSeconds: 1500,
        sessionType: SessionType.pomodoro,
        dateCreated: dateCreated,
      );

      // Act
      final map = session.toMap();

      // Assert
      expect(map['id'], equals(1));
      expect(map['task_id'], equals(3));
      expect(map['start_time'], equals(startTime.millisecondsSinceEpoch));
      expect(map['end_time'], equals(endTime.millisecondsSinceEpoch));
      expect(map['duration_seconds'], equals(1500));
      expect(map['session_type'], equals(1)); // pomodoro index
      expect(map['date_created'], equals(dateCreated.millisecondsSinceEpoch));
    });

    test('should format duration correctly', () {
      // Arrange
      final startTime = DateTime.now();
      final dateCreated = DateTime.now();
      
      // Test different durations
      final session1 = StudySession(
        taskId: 1,
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 1, minutes: 30)),
        durationInSeconds: 5400, // 1h 30m
        sessionType: SessionType.pomodoro,
        dateCreated: dateCreated,
      );
      
      final session2 = StudySession(
        taskId: 1,
        startTime: startTime,
        endTime: startTime.add(const Duration(minutes: 5, seconds: 30)),
        durationInSeconds: 330, // 5m 30s
        sessionType: SessionType.stopwatch,
        dateCreated: dateCreated,
      );
      
      final session3 = StudySession(
        taskId: 1,
        startTime: startTime,
        endTime: startTime.add(const Duration(seconds: 45)),
        durationInSeconds: 45, // 45s
        sessionType: SessionType.stopwatch,
        dateCreated: dateCreated,
      );

      // Assert
      expect(session1.formattedDuration, equals('1h 30m 0s'));
      expect(session2.formattedDuration, equals('5m 30s'));
      expect(session3.formattedDuration, equals('45s'));
    });

    test('should handle session type enum', () {
      // Test enum values
      expect(SessionType.stopwatch.index, equals(0));
      expect(SessionType.pomodoro.index, equals(1));
      
      // Test enum from index
      expect(SessionType.values[0], equals(SessionType.stopwatch));
      expect(SessionType.values[1], equals(SessionType.pomodoro));
    });

    test('should create session with null id for new sessions', () {
      // Arrange & Act
      final session = StudySession(
        taskId: 1,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 25)),
        durationInSeconds: 1500,
        sessionType: SessionType.pomodoro,
        dateCreated: DateTime.now(),
      );

      // Assert
      expect(session.id, isNull);
      expect(session.taskId, equals(1));
      expect(session.durationInSeconds, equals(1500));
    });

    test('should copy session with updated fields', () {
      // Arrange
      final startTime = DateTime.now();
      final endTime = startTime.add(const Duration(minutes: 25));
      final dateCreated = DateTime.now();
      final originalSession = StudySession(
        id: 1,
        taskId: 1,
        startTime: startTime,
        endTime: endTime,
        durationInSeconds: 1500,
        sessionType: SessionType.pomodoro,
        dateCreated: dateCreated,
      );

      // Act
      final updatedSession = originalSession.copyWith(
        taskId: 2,
        sessionType: SessionType.stopwatch,
      );

      // Assert
      expect(updatedSession.id, equals(originalSession.id));
      expect(updatedSession.taskId, equals(2));
      expect(updatedSession.sessionType, equals(SessionType.stopwatch));
      expect(updatedSession.startTime, equals(originalSession.startTime));
      expect(updatedSession.endTime, equals(originalSession.endTime));
      expect(updatedSession.durationInSeconds, equals(originalSession.durationInSeconds));
    });
  });
}
