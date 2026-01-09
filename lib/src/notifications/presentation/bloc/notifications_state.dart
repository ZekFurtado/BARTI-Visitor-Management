part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

/// Initial state
class NotificationsInitial extends NotificationsState {}

/// Loading notifications
class NotificationsLoading extends NotificationsState {}

/// Notifications loaded successfully
class NotificationsLoaded extends NotificationsState {
  final List<NotificationModel> notifications;

  const NotificationsLoaded({required this.notifications});

  @override
  List<Object> get props => [notifications];

  /// Get unread notifications count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Get notifications by type
  List<NotificationModel> getByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }
}

/// Error loading notifications
class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object> get props => [message];
}