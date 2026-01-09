import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.data,
    required super.recipientId,
    required super.createdAt,
    required super.type,
    super.isRead = false,
    super.readAt,
  });

  /// Create NotificationModel from Firestore document
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      data: Map<String, String>.from(data['data'] ?? {}),
      recipientId: data['recipientId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      type: NotificationType.values.firstWhere(
        (type) => type.toString().split('.').last == data['type'],
        orElse: () => NotificationType.general,
      ),
      isRead: data['isRead'] ?? false,
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Convert NotificationModel to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'data': data,
      'recipientId': recipientId,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type.toString().split('.').last,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  /// Create NotificationModel from FCM payload
  factory NotificationModel.fromFCMPayload({
    required Map<String, dynamic> notification,
    required Map<String, dynamic> data,
    required String recipientId,
  }) {
    return NotificationModel(
      id: '', // Will be set when saved to Firestore
      title: notification['title'] ?? '',
      body: notification['body'] ?? '',
      data: Map<String, String>.from(data),
      recipientId: recipientId,
      createdAt: DateTime.now(),
      type: _getTypeFromData(data),
      isRead: false,
    );
  }

  /// Determine notification type from FCM data payload
  static NotificationType _getTypeFromData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    switch (type) {
      case 'visitor_request':
        return NotificationType.request;
      case 'visitor_approved':
      case 'visitor_approval':
        return NotificationType.approval;
      case 'visitor_rejected':
      case 'visitor_rejection':
        return NotificationType.rejection;
      case 'visitor_checkin':
        return NotificationType.checkin;
      case 'visitor_checkout':
        return NotificationType.checkout;
      default:
        return NotificationType.general;
    }
  }

  /// Copy with method for updating notification
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, String>? data,
    String? recipientId,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      recipientId: recipientId ?? this.recipientId,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }
}