import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Sample notifications (in real app, would come from Firestore)
    final notifications = [
      NotificationItem(
        id: '1',
        title: 'Ticket #123 Resolved',
        message: 'Your ticket "Broken Office Chair" has been marked as resolved.',
        type: NotificationType.resolved,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Ticket Updated',
        message: 'Your ticket "WiFi Not Working" is now in progress.',
        type: NotificationType.inProgress,
        time: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'New Comment',
        message: 'Admin added a comment on your ticket #456.',
        type: NotificationType.comment,
        time: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'System Maintenance',
        message: 'Scheduled maintenance on Dec 15, 2024 at 2:00 AM.',
        type: NotificationType.system,
        time: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        backgroundColor: authProvider.isAdmin
            ? AppColors.accentOrange
            : AppColors.primaryTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: AppColors.primaryTeal,
                ),
              );
            },
            child: const Text(
              'Mark all read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationTile(context, notification);
              },
            ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : AppColors.backgroundTeal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(notification.time),
              style: TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
              ),
            ),
          ],
        ),
        onTap: () {
          // Handle notification tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening: ${notification.title}'),
              backgroundColor: AppColors.primaryTeal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: AppColors.primaryTeal,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Notifications',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!\nNew notifications will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.resolved:
        return Icons.check_circle_outline;
      case NotificationType.inProgress:
        return Icons.pending_outlined;
      case NotificationType.comment:
        return Icons.chat_bubble_outline;
      case NotificationType.system:
        return Icons.settings_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.resolved:
        return AppColors.statusResolved;
      case NotificationType.inProgress:
        return AppColors.statusInProgress;
      case NotificationType.comment:
        return AppColors.primaryTeal;
      case NotificationType.system:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

enum NotificationType {
  resolved,
  inProgress,
  comment,
  system,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime time;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
  });
}

