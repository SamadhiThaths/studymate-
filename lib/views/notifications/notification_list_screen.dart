import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification.dart' as app_notification;
import '../../utils/app_utils.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<NotificationProvider>(context, listen: false).loadNotifications();
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error loading notifications: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
      if (mounted) {
        AppUtils.showSnackBar(context, 'All notifications marked as read');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    try {
      await Provider.of<NotificationProvider>(context, listen: false).deleteAllNotifications();
      if (mounted) {
        AppUtils.showSnackBar(context, 'All notifications cleared');
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear all notifications',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Notifications'),
                  content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearAllNotifications();
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  final notifications = notificationProvider.notifications;

                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notifications',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(context, notification);
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, app_notification.Notification notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<NotificationProvider>(context, listen: false).deleteNotification(notification.id);
        AppUtils.showSnackBar(context, 'Notification deleted');
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: notification.isRead ? null : Colors.blue.shade50,
        child: ListTile(
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(notification.message),
              const SizedBox(height: 4),
              Text(
                AppUtils.formatDateTime(notification.createdAt),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          isThreeLine: true,
          onTap: () {
            if (!notification.isRead) {
              Provider.of<NotificationProvider>(context, listen: false).markAsRead(notification.id);
            }
            
            // If the notification is related to an assignment, navigate to the assignment details
            if (notification.relatedEntityType == 'assignment' && notification.relatedEntityId != null) {
              // TODO: Navigate to assignment details screen
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => AssignmentDetailScreen(assignmentId: notification.relatedEntityId!),
              //   ),
              // );
            }
          },
        ),
      ),
    );
  }
}