import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../controllers/notification_controller.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationController _controller = NotificationController();
  
  List<Notification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get unread notifications count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  // Load all notifications
  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _controller.getAllNotifications();
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Sort by newest first
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Load only unread notifications
  Future<void> loadUnreadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _controller.getUnreadNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  // Create a new notification
  Future<void> addNotification({
    required String title,
    required String message,
    String? relatedEntityId,
    String? relatedEntityType,
  }) async {
    _setLoading(true);
    try {
      final notification = await _controller.createNotification(
        title: title,
        message: message,
        relatedEntityId: relatedEntityId,
        relatedEntityType: relatedEntityType,
      );
      
      _notifications.insert(0, notification); // Add to the beginning of the list
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Create a notification for completed assignment
  Future<void> addAssignmentCompletionNotification({
    required String assignmentId,
    required String assignmentName,
  }) async {
    _setLoading(true);
    try {
      final notification = await _controller.createAssignmentCompletionNotification(
        assignmentId: assignmentId,
        assignmentName: assignmentName,
      );
      
      _notifications.insert(0, notification); // Add to the beginning of the list
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Mark a notification as read
  Future<void> markAsRead(String id) async {
    try {
      await _controller.markAsRead(id);
      
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }
      
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    _setLoading(true);
    try {
      await _controller.markAllAsRead();
      
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Delete a notification
  Future<void> deleteNotification(String id) async {
    try {
      await _controller.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      notifyListeners();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
  
  // Delete all notifications
  Future<void> deleteAllNotifications() async {
    _setLoading(true);
    try {
      await _controller.deleteAllNotifications();
      _notifications.clear();
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}