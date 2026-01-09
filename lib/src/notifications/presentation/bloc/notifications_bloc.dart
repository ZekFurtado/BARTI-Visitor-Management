import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/notification_models.dart';
import '../../data/models/notification_model.dart';
import '../../data/datasources/notification_remote_data_source.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationRemoteDataSource _dataSource;

  NotificationsBloc({required NotificationRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<SubscribeToNotificationsEvent>(_onSubscribeToNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<SaveNotificationEvent>(_onSaveNotification);
    on<DeleteNotificationEvent>(_onDeleteNotification);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      emit(NotificationsLoading());
      
      log('📱 Loading notifications for user: ${event.userId}');
      final notifications = await _dataSource.getNotificationsForUser(event.userId);
      
      emit(NotificationsLoaded(notifications: notifications));
      log('✅ Loaded ${notifications.length} notifications');
    } catch (e) {
      log('❌ Error loading notifications: $e');
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onSubscribeToNotifications(
    SubscribeToNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      log('📡 Subscribing to notifications stream for user: ${event.userId}');
      
      await emit.forEach(
        _dataSource.getNotificationsStream(event.userId),
        onData: (notifications) {
          log('📱 Received ${notifications.length} notifications from stream');
          return NotificationsLoaded(notifications: notifications);
        },
        onError: (error, stackTrace) {
          log('❌ Notifications stream error: $error');
          return NotificationsError(message: error.toString());
        },
      );
    } catch (e) {
      log('❌ Error setting up notifications stream: $e');
      emit(NotificationsError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _dataSource.markNotificationAsRead(event.notificationId);
      log('✅ Notification marked as read: ${event.notificationId}');
    } catch (e) {
      log('❌ Error marking notification as read: $e');
      // Don't emit error state for this, as it's not critical to the UI
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _dataSource.markAllNotificationsAsRead(event.userId);
      log('✅ All notifications marked as read for user: ${event.userId}');
    } catch (e) {
      log('❌ Error marking all notifications as read: $e');
      // Don't emit error state for this, as it's not critical to the UI
    }
  }

  Future<void> _onSaveNotification(
    SaveNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final savedNotification = await _dataSource.saveNotification(event.notification);
      log('✅ Notification saved: ${savedNotification.title}');
      // The stream will automatically update the UI with the new notification
    } catch (e) {
      log('❌ Error saving notification: $e');
      // Don't emit error state for this, as it's not critical to the UI
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _dataSource.deleteNotification(event.notificationId);
      log('✅ Notification deleted: ${event.notificationId}');
    } catch (e) {
      log('❌ Error deleting notification: $e');
      // Don't emit error state for this, as it's not critical to the UI
    }
  }
}