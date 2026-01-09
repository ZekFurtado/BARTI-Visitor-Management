import 'package:equatable/equatable.dart';

/// Notification entity representing a push notification received by the user
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final Map<String, String> data;
  final String recipientId;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.recipientId,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        data,
        recipientId,
        createdAt,
        type,
        isRead,
        readAt,
      ];
}

/// Types of notifications that can be received
enum NotificationType {
  /// New visitor request notification
  request,
  
  /// Visitor approved notification
  approval,
  
  /// Visitor rejected notification
  rejection,
  
  /// Visitor checked in notification
  checkin,
  
  /// Visitor checked out notification
  checkout,
  
  /// General notification
  general,
}