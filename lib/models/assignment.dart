class Assignment {
  String id;
  String name;
  String moduleCode;
  DateTime dueDate;
  String status; // 'Not Started', 'In Progress', 'Completed', 'Overdue'
  String? description;
  DateTime createdAt;

  Assignment({
    required this.id,
    required this.name,
    required this.moduleCode,
    required this.dueDate,
    required this.status,
    this.description,
    required this.createdAt,
  });

  // Convert Assignment to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'moduleCode': moduleCode,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'status': status,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create Assignment from Map (from database)
  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      name: map['name'],
      moduleCode: map['moduleCode'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      status: map['status'],
      description: map['description'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  // Create a copy of Assignment with some fields changed
  Assignment copyWith({
    String? id,
    String? name,
    String? moduleCode,
    DateTime? dueDate,
    String? status,
    String? description,
    DateTime? createdAt,
  }) {
    return Assignment(
      id: id ?? this.id,
      name: name ?? this.name,
      moduleCode: moduleCode ?? this.moduleCode,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}