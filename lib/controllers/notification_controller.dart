import 'package:uuid/uuid.dart';
import '../models/notification.dart';
import '../services/db_service.dart';

class NotificationController {
  final DBService _dbService = DBService();
  final Uuid _uuid = Uuid();

  // Get all notifications
  Future<List<Notification>> getAllNotifications() async {
    return await _dbService.getAllNotifications();
  }

  // Get unread notifications
  Future<List<Notification>> getUnreadNotifications() async {
    return await _dbService.getUnreadNotifications();
  }

  // Create a new notification
  Future<Notification> createNotification({
    required String title,
    required String message,
    String? relatedEntityId,
    String? relatedEntityType,
  }) async {
    // Validate inputs
    if (title.isEmpty) {
      throw Exception('Notification title is required');
    }
    if (message.isEmpty) {
      throw Exception('Notification message is required');
    }

    final notification = Notification(
      id: _uuid.v4(),
      title: title,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
    );

    await _dbService.insertNotification(notification);
    return notification;
  }

  // Create a notification for completed assignment
  Future<Notification> createAssignmentCompletionNotification({
    required String assignmentId,
    required String assignmentName,
  }) async {
    final notification = Notification.forCompletedAssignment(
      assignmentId: assignmentId,
      assignmentName: assignmentName,
      completedAt: DateTime.now(),
    );

    await _dbService.insertNotification(notification);
    return notification;
  }

  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    await _dbService.markNotificationAsRead(id);
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    await _dbService.markAllNotificationsAsRead();
  }

  // Delete a notification
  Future<void> deleteNotification(String id) async {
    await _dbService.deleteNotification(id);
  }

  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    await _dbService.deleteAllNotifications();
  }
}