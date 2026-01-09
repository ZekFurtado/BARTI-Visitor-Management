import 'package:equatable/equatable.dart';

/// Enum for notification types
enum NotificationType {
  visitorArrival('visitor_arrival'),
  visitorApproval('visitor_approval'),
  visitorRejection('visitor_rejection'),
  general('general');

  const NotificationType(this.value);
  
  final String value;
  
  static NotificationType fromString(String value) {
    switch (value) {
      case 'visitor_arrival':
        return NotificationType.visitorArrival;
      case 'visitor_approval':
        return NotificationType.visitorApproval;
      case 'visitor_rejection':
        return NotificationType.visitorRejection;
      case 'general':
        return NotificationType.general;
      default:
        return NotificationType.general;
    }
  }
}

/// Base notification data model
class NotificationData extends Equatable {
  const NotificationData({
    required this.type,
    required this.title,
    required this.body,
    this.data = const {},
    this.timestamp,
  });

  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? timestamp;

  /// Create a visitor arrival notification
  factory NotificationData.visitorArrival({
    required String visitorName,
    required String visitorOrigin,
    required String visitorPurpose,
    required String gatekeeperName,
    String? visitorId,
    String? employeeId,
  }) {
    return NotificationData(
      type: NotificationType.visitorArrival,
      title: 'New Visitor Arrival',
      body: '$visitorName from $visitorOrigin wants to meet you',
      data: {
        'visitorId': visitorId ?? '',
        'visitorName': visitorName,
        'visitorOrigin': visitorOrigin,
        'visitorPurpose': visitorPurpose,
        'gatekeeperName': gatekeeperName,
        'employeeId': employeeId ?? '',
        'action': 'visitor_arrival',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create a visitor approval notification
  factory NotificationData.visitorApproval({
    required String visitorName,
    required String employeeName,
    String? visitorId,
    String? gatekeeperId,
  }) {
    return NotificationData(
      type: NotificationType.visitorApproval,
      title: 'Visitor Approved',
      body: '$employeeName has approved the visit by $visitorName',
      data: {
        'visitorId': visitorId ?? '',
        'visitorName': visitorName,
        'employeeName': employeeName,
        'gatekeeperId': gatekeeperId ?? '',
        'action': 'visitor_approved',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Create a visitor rejection notification
  factory NotificationData.visitorRejection({
    required String visitorName,
    required String employeeName,
    String? reason,
    String? visitorId,
    String? gatekeeperId,
  }) {
    return NotificationData(
      type: NotificationType.visitorRejection,
      title: 'Visitor Request Rejected',
      body: '$employeeName has rejected the visit by $visitorName${reason != null ? ': $reason' : ''}',
      data: {
        'visitorId': visitorId ?? '',
        'visitorName': visitorName,
        'employeeName': employeeName,
        'rejectionReason': reason ?? '',
        'gatekeeperId': gatekeeperId ?? '',
        'action': 'visitor_rejected',
      },
      timestamp: DateTime.now(),
    );
  }

  /// Convert to Map for FCM payload
  Map<String, dynamic> toFCMPayload() {
    return {
      'notification': {
        'title': title,
        'body': body,
      },
      'data': {
        ...data,
        'type': type.value,
        'timestamp': timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
      },
      'priority': 'high',
    };
  }

  /// Convert to Map for local storage or API
  Map<String, dynamic> toMap() {
    return {
      'type': type.value,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Create from Map
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      type: NotificationType.fromString(map['type'] as String? ?? 'general'),
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: Map<String, dynamic>.from(map['data'] as Map? ?? {}),
      timestamp: map['timestamp'] != null 
          ? DateTime.tryParse(map['timestamp'] as String) 
          : null,
    );
  }

  @override
  List<Object?> get props => [type, title, body, data, timestamp];

  /// Create a copy with updated values
  NotificationData copyWith({
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
  }) {
    return NotificationData(
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Model for storing notification history
class NotificationHistory extends Equatable {
  const NotificationHistory({
    this.id,
    required this.userId,
    required this.notificationData,
    required this.sentAt,
    this.readAt,
    this.isRead = false,
  });

  final String? id;
  final String userId;
  final NotificationData notificationData;
  final DateTime sentAt;
  final DateTime? readAt;
  final bool isRead;

  /// Convert to Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': notificationData.type.value,
      'title': notificationData.title,
      'body': notificationData.body,
      'data': notificationData.data,
      'sentAt': sentAt,
      'readAt': readAt,
      'isRead': isRead,
    };
  }

  /// Create from Firestore document
  factory NotificationHistory.fromFirestore(Map<String, dynamic> doc, String id) {
    return NotificationHistory(
      id: id,
      userId: doc['userId'] as String,
      notificationData: NotificationData(
        type: NotificationType.fromString(doc['type'] as String? ?? 'general'),
        title: doc['title'] as String? ?? '',
        body: doc['body'] as String? ?? '',
        data: Map<String, dynamic>.from(doc['data'] as Map? ?? {}),
        timestamp: (doc['sentAt'] as DateTime?) ?? DateTime.now(),
      ),
      sentAt: doc['sentAt'] as DateTime? ?? DateTime.now(),
      readAt: doc['readAt'] as DateTime?,
      isRead: doc['isRead'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, userId, notificationData, sentAt, readAt, isRead];

  /// Mark notification as read
  NotificationHistory markAsRead() {
    return NotificationHistory(
      id: id,
      userId: userId,
      notificationData: notificationData,
      sentAt: sentAt,
      readAt: DateTime.now(),
      isRead: true,
    );
  }
}