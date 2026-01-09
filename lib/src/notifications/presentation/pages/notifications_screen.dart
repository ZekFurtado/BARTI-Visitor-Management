import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/domain/entities/user.dart';
import '../bloc/notifications_bloc.dart';
import '../../data/models/notification_model.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.user});

  final LocalUser user;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Subscribe to real-time notifications stream
    context.read<NotificationsBloc>().add(
      SubscribeToNotificationsEvent(userId: widget.user.uid ?? ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        final unreadCount = state is NotificationsLoaded 
            ? state.unreadCount 
            : 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            actions: [
              if (unreadCount > 0)
                TextButton(
                  onPressed: () => _markAllAsRead(context),
                  child: Text(
                    'Mark all read',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              if (unreadCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _buildNotificationsBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsBody(NotificationsState state) {
    if (state is NotificationsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is NotificationsError) {
      return _buildErrorState(state.message);
    } else if (state is NotificationsLoaded) {
      if (state.notifications.isEmpty) {
        return _buildEmptyState();
      } else {
        return ListView.builder(
          itemCount: state.notifications.length,
          itemBuilder: (context, index) {
            final notification = state.notifications[index];
            return _buildNotificationTile(notification);
          },
        );
      }
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications about visitor requests and updates here.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NotificationsBloc>().add(
                  SubscribeToNotificationsEvent(userId: widget.user.uid ?? ''),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel notification) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead 
            ? null 
            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: _getNotificationColor(notification.type),
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
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
              notification.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(context, notification),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.request:
        return Icons.person_add;
      case NotificationType.approval:
        return Icons.check_circle;
      case NotificationType.rejection:
        return Icons.cancel;
      case NotificationType.checkin:
        return Icons.login;
      case NotificationType.checkout:
        return Icons.logout;
      case NotificationType.general:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.request:
        return Colors.blue;
      case NotificationType.approval:
        return Colors.green;
      case NotificationType.rejection:
        return Colors.red;
      case NotificationType.checkin:
        return Colors.orange;
      case NotificationType.checkout:
        return Colors.grey;
      case NotificationType.general:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'Yesterday' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Mark notification as read if it isn't already
    if (!notification.isRead) {
      context.read<NotificationsBloc>().add(
        MarkNotificationAsReadEvent(notificationId: notification.id),
      );
    }

    // Navigate based on notification type or show details
    final data = notification.data;
    final visitorId = data['visitorId'];
    
    if (visitorId != null) {
      // TODO: Navigate to visitor details or relevant screen
      // For now, show a dialog with notification details
      _showNotificationDetails(context, notification);
    } else {
      _showNotificationDetails(context, notification);
    }
  }

  void _showNotificationDetails(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            if (notification.data.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...notification.data.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${entry.key}: ${entry.value}'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead(BuildContext context) {
    context.read<NotificationsBloc>().add(
      MarkAllNotificationsAsReadEvent(userId: widget.user.uid ?? ''),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}