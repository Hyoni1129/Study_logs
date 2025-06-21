enum SessionType {
  stopwatch,
  pomodoro,
}

class StudySession {
  final int? id;
  final int taskId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationInSeconds;
  final SessionType sessionType;
  final DateTime dateCreated;

  StudySession({
    this.id,
    required this.taskId,
    required this.startTime,
    required this.endTime,
    required this.durationInSeconds,
    required this.sessionType,
    required this.dateCreated,
  });

  // Convert StudySession to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'start_time': startTime.millisecondsSinceEpoch,
      'end_time': endTime.millisecondsSinceEpoch,
      'duration_seconds': durationInSeconds,
      'session_type': sessionType.index,
      'date_created': dateCreated.millisecondsSinceEpoch,
    };
  }

  // Create StudySession from Map (database retrieval)
  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id']?.toInt(),
      taskId: map['task_id']?.toInt() ?? 0,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['start_time']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['end_time']),
      durationInSeconds: map['duration_seconds']?.toInt() ?? 0,
      sessionType: SessionType.values[map['session_type'] ?? 0],
      dateCreated: DateTime.fromMillisecondsSinceEpoch(map['date_created']),
    );
  }

  // Create a copy of the session with updated fields
  StudySession copyWith({
    int? id,
    int? taskId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationInSeconds,
    SessionType? sessionType,
    DateTime? dateCreated,
  }) {
    return StudySession(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationInSeconds: durationInSeconds ?? this.durationInSeconds,
      sessionType: sessionType ?? this.sessionType,
      dateCreated: dateCreated ?? this.dateCreated,
    );
  }

  // Get formatted duration
  String get formattedDuration {
    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;
    final seconds = durationInSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Get session type as string
  String get sessionTypeString {
    switch (sessionType) {
      case SessionType.stopwatch:
        return 'Stopwatch';
      case SessionType.pomodoro:
        return 'Pomodoro';
    }
  }

  // Get date as string (without time)
  String get dateString {
    return '${dateCreated.year}-${dateCreated.month.toString().padLeft(2, '0')}-${dateCreated.day.toString().padLeft(2, '0')}';
  }

  // Check if session is from today
  bool get isToday {
    final now = DateTime.now();
    return dateCreated.year == now.year &&
           dateCreated.month == now.month &&
           dateCreated.day == now.day;
  }

  // Check if session is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    return dateCreated.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
           dateCreated.isBefore(endOfWeek.add(Duration(days: 1)));
  }

  // Check if session is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return dateCreated.year == now.year && dateCreated.month == now.month;
  }

  @override
  String toString() {
    return 'StudySession{id: $id, taskId: $taskId, startTime: $startTime, endTime: $endTime, durationInSeconds: $durationInSeconds, sessionType: $sessionType, dateCreated: $dateCreated}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          taskId == other.taskId &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          durationInSeconds == other.durationInSeconds &&
          sessionType == other.sessionType &&
          dateCreated == other.dateCreated;

  @override
  int get hashCode =>
      id.hashCode ^
      taskId.hashCode ^
      startTime.hashCode ^
      endTime.hashCode ^
      durationInSeconds.hashCode ^
      sessionType.hashCode ^
      dateCreated.hashCode;
}
