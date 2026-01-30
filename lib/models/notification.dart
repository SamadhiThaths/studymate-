import 'package:uuid/uuid.dart';

class Notification {
  String id;
  String title;
  String message;
  DateTime createdAt;
  bool isRead;
  String? relatedEntityId; // ID of the related entity (e.g., assignment ID)
  String? relatedEntityType; // Type of the related entity (e.g., 'assignment')

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.relatedEntityId,
    this.relatedEntityType,
  });

  // Convert Notification to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead ? 1 : 0,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
    };
  }

  // Create Notification from Map (from database)
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] == 1,
      relatedEntityId: map['relatedEntityId'],
      relatedEntityType: map['relatedEntityType'],
    );
  }

  // Create a copy of Notification with some fields changed
  Notification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? relatedEntityId,
    String? relatedEntityType,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
    );
  }

  // Factory method to create a notification for completed assignment
  factory Notification.forCompletedAssignment({
    required String assignmentId,
    required String assignmentName,
    required DateTime completedAt,
  }) {
    return Notification(
      id: const Uuid().v4(),
      title: 'Assignment Completed',
      message: 'You have completed the assignment "$assignmentName" on ${_formatDate(completedAt)}',
      createdAt: DateTime.now(),
      relatedEntityId: assignmentId,
      relatedEntityType: 'assignment',
    );
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}