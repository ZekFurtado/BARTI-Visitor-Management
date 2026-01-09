import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Save notification to Firestore
  Future<NotificationModel> saveNotification(NotificationModel notification);
  
  /// Get notifications for a specific user
  Future<List<NotificationModel>> getNotificationsForUser(String userId);
  
  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId);
  
  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId);
  
  /// Get real-time stream of notifications for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId);
  
  /// Delete notification
  Future<void> deleteNotification(String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  
  NotificationRemoteDataSourceImpl({required this.firestore});

  @override
  Future<NotificationModel> saveNotification(NotificationModel notification) async {
    try {
      log('💾 Saving notification to Firestore: ${notification.title}');
      
      final docRef = await firestore
          .collection('notifications')
          .add(notification.toFirestore());
      
      final doc = await docRef.get();
      final savedNotification = NotificationModel.fromFirestore(doc);
      
      log('✅ Notification saved with ID: ${savedNotification.id}');
      return savedNotification;
    } catch (e) {
      log('❌ Error saving notification: $e');
      rethrow;
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    try {
      log('📱 Fetching notifications for user: $userId');
      
      final querySnapshot = await firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final notifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
      
      log('✅ Fetched ${notifications.length} notifications for user $userId');
      return notifications;
    } catch (e) {
      log('❌ Error fetching notifications for user: $e');
      rethrow;
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      log('📖 Marking notification as read: $notificationId');
      
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
            'isRead': true,
            'readAt': Timestamp.now(),
          });
      
      log('✅ Notification marked as read');
    } catch (e) {
      log('❌ Error marking notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      log('📖 Marking all notifications as read for user: $userId');
      
      final querySnapshot = await firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
      
      await batch.commit();
      log('✅ All notifications marked as read for user $userId');
    } catch (e) {
      log('❌ Error marking all notifications as read: $e');
      rethrow;
    }
  }

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    try {
      log('📡 Setting up real-time notifications stream for user: $userId');
      
      return firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final notifications = snapshot.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList();
            
            log('📱 Notifications stream update: ${notifications.length} notifications');
            return notifications;
          });
    } catch (e) {
      log('❌ Error setting up notifications stream: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      log('🗑️ Deleting notification: $notificationId');
      
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .delete();
      
      log('✅ Notification deleted');
    } catch (e) {
      log('❌ Error deleting notification: $e');
      rethrow;
    }
  }
}