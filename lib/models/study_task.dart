class StudyTask {
  String id;
  String subject;
  String task;
  DateTime date;
  int durationMinutes;
  bool isDone;
  DateTime createdAt;

  StudyTask({
    required this.id,
    required this.subject,
    required this.task,
    required this.date,
    required this.durationMinutes,
    this.isDone = false,
    required this.createdAt,
  });

  // Convert StudyTask to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'task': task,
      'date': date.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create StudyTask from Map (from database)
  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      id: map['id'],
      subject: map['subject'],
      task: map['task'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      durationMinutes: map['durationMinutes'],
      isDone: map['isDone'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy of StudyTask with some fields changed
  StudyTask copyWith({
    String? id,
    String? subject,
    String? task,
    DateTime? date,
    int? durationMinutes,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return StudyTask(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      task: task ?? this.task,
      date: date ?? this.date,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}