part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

/// Load notifications for a specific user
class LoadNotificationsEvent extends NotificationsEvent {
  final String userId;

  const LoadNotificationsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Subscribe to real-time notifications stream for a user
class SubscribeToNotificationsEvent extends NotificationsEvent {
  final String userId;

  const SubscribeToNotificationsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Mark a specific notification as read
class MarkNotificationAsReadEvent extends NotificationsEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}

/// Mark all notifications as read for a user
class MarkAllNotificationsAsReadEvent extends NotificationsEvent {
  final String userId;

  const MarkAllNotificationsAsReadEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Save a new notification to the database
class SaveNotificationEvent extends NotificationsEvent {
  final NotificationModel notification;

  const SaveNotificationEvent({required this.notification});

  @override
  List<Object> get props => [notification];
}

/// Delete a notification
class DeleteNotificationEvent extends NotificationsEvent {
  final String notificationId;

  const DeleteNotificationEvent({required this.notificationId});

  @override
  List<Object> get props => [notificationId];
}