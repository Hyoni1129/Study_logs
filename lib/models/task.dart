class Task {
  final int? id;
  final String name;
  final DateTime createdAt;
  final DateTime lastModified;
  final int totalTimeInSeconds;

  Task({
    this.id,
    required this.name,
    required this.createdAt,
    required this.lastModified,
    this.totalTimeInSeconds = 0,
  });

  // Convert Task to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_modified': lastModified.millisecondsSinceEpoch,
      'total_time_seconds': totalTimeInSeconds,
    };
  }

  // Create Task from Map (database retrieval)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastModified: DateTime.fromMillisecondsSinceEpoch(map['last_modified']),
      totalTimeInSeconds: map['total_time_seconds']?.toInt() ?? 0,
    );
  }

  // Create a copy of the task with updated fields
  Task copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? lastModified,
    int? totalTimeInSeconds,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      totalTimeInSeconds: totalTimeInSeconds ?? this.totalTimeInSeconds,
    );
  }

  // Get formatted total time
  String get formattedTotalTime {
    final hours = totalTimeInSeconds ~/ 3600;
    final minutes = (totalTimeInSeconds % 3600) ~/ 60;
    final seconds = totalTimeInSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name, createdAt: $createdAt, lastModified: $lastModified, totalTimeInSeconds: $totalTimeInSeconds}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Task &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          createdAt == other.createdAt &&
          lastModified == other.lastModified &&
          totalTimeInSeconds == other.totalTimeInSeconds;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      createdAt.hashCode ^
      lastModified.hashCode ^
      totalTimeInSeconds.hashCode;
}
