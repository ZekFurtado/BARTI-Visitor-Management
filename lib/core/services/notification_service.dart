import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';
import '../models/notification_models.dart';

/// Service for handling push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;
  
  // FCM HTTP v1 API configuration
  static const String _projectId = 'visitor-management-e97f4';
  static const String _fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  
  // Service account credentials loaded from assets
  static Map<String, dynamic>? _serviceAccountConfig;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Navigation key for global navigation
  static GlobalKey<NavigatorState>? _navigatorKey;
  
  /// Set the navigator key for navigation handling
  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Initialize the notification service
  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Initialize Firebase Messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission for notifications');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('User granted provisional permission for notifications');
    } else {
      log('User declined or has not accepted permission for notifications');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      log('FCM Token: $token');
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Store FCM token for a user in Firestore
  Future<bool> storeFCMToken(String userId, String fcmToken) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': fcmToken,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      log('FCM token stored successfully for user: $userId');
      return true;
    } catch (e) {
      log('Error storing FCM token: $e');
      return false;
    }
  }

  /// Get FCM token for a specific user
  Future<String?> getUserFCMToken(String userId) async {
    try {
      log('🔍 Looking for FCM token for user: $userId');
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data();
        final fcmToken = data?['fcmToken'] as String?;
        
        if (fcmToken != null) {
          log('✅ Found FCM token for user: ${fcmToken.substring(0, 20)}...');
        } else {
          log('❌ No FCM token found for user: $userId');
          log('📄 User data: ${data?.keys.toList()}');
        }
        
        return fcmToken;
      } else {
        log('❌ User document not found: $userId');
        return null;
      }
    } catch (e) {
      log('❌ Error getting user FCM token: $e');
      return null;
    }
  }

  /// Send visitor notification to specific employee
  Future<bool> sendVisitorNotification({
    required String employeeId,
    required String visitorName,
    required String visitorOrigin,
    required String visitorPurpose,
    required String gatekeeperName,
    String? visitorId,
  }) async {
    try {
      // Get employee's FCM token
      final fcmToken = await getUserFCMToken(employeeId);
      if (fcmToken == null) {
        log('No FCM token found for employee: $employeeId');
        return false;
      }

      // Create notification data using the model
      final notificationData = NotificationData.visitorArrival(
        visitorName: visitorName,
        visitorOrigin: visitorOrigin,
        visitorPurpose: visitorPurpose,
        gatekeeperName: gatekeeperName,
        visitorId: visitorId,
        employeeId: employeeId,
      );

      // Send notification
      final success = await _sendNotificationWithData(
        fcmToken: fcmToken,
        notificationData: notificationData,
      );

      // Store notification history
      if (success) {
        await _storeNotificationHistory(employeeId, notificationData);
      }

      return success;
    } catch (e) {
      log('Error sending visitor notification: $e');
      return false;
    }
  }

  /// Send visitor approval notification to gatekeeper
  Future<bool> sendVisitorApprovalNotification({
    required String gatekeeperId,
    required String visitorName,
    required String employeeName,
    String? visitorId,
  }) async {
    try {
      final fcmToken = await getUserFCMToken(gatekeeperId);
      if (fcmToken == null) {
        log('No FCM token found for gatekeeper: $gatekeeperId');
        return false;
      }

      final notificationData = NotificationData.visitorApproval(
        visitorName: visitorName,
        employeeName: employeeName,
        visitorId: visitorId,
        gatekeeperId: gatekeeperId,
      );

      final success = await _sendNotificationWithData(
        fcmToken: fcmToken,
        notificationData: notificationData,
      );

      if (success) {
        await _storeNotificationHistory(gatekeeperId, notificationData);
      }

      return success;
    } catch (e) {
      log('Error sending visitor approval notification: $e');
      return false;
    }
  }

  /// Send visitor rejection notification to gatekeeper
  Future<bool> sendVisitorRejectionNotification({
    required String gatekeeperId,
    required String visitorName,
    required String employeeName,
    String? reason,
    String? visitorId,
  }) async {
    try {
      final fcmToken = await getUserFCMToken(gatekeeperId);
      if (fcmToken == null) {
        log('No FCM token found for gatekeeper: $gatekeeperId');
        return false;
      }

      final notificationData = NotificationData.visitorRejection(
        visitorName: visitorName,
        employeeName: employeeName,
        reason: reason,
        visitorId: visitorId,
        gatekeeperId: gatekeeperId,
      );

      final success = await _sendNotificationWithData(
        fcmToken: fcmToken,
        notificationData: notificationData,
      );

      if (success) {
        await _storeNotificationHistory(gatekeeperId, notificationData);
      }

      return success;
    } catch (e) {
      log('Error sending visitor rejection notification: $e');
      return false;
    }
  }

  /// Load service account configuration from assets
  Future<bool> _loadServiceAccountConfig() async {
    if (_serviceAccountConfig != null) return true;
    
    try {
      // Try to load service account from assets
      final String configString = await rootBundle.loadString('assets/config/service_account.json');
      _serviceAccountConfig = jsonDecode(configString);
      return true;
    } catch (e) {
      log('❌ Failed to load service account configuration: $e');
      log('🔧 Please ensure assets/config/service_account.json exists with valid Firebase service account credentials');
      log('🔧 You can copy assets/config/service_account_template.json and fill in the real values');
      return false;
    }
  }
  
  /// Get OAuth2 access token for FCM HTTP v1 API
  Future<String?> _getAccessToken() async {
    try {
      // Load service account configuration if needed
      if (!await _loadServiceAccountConfig()) {
        return null;
      }
      
      // Check if service account is properly configured
      if (_serviceAccountConfig == null || 
          _serviceAccountConfig!['private_key'] == 'YOUR_PRIVATE_KEY' ||
          _serviceAccountConfig!['private_key'] == null) {
        log('❌ Service account credentials not configured!');
        log('🔧 Please configure the service account credentials in assets/config/service_account.json');
        return null;
      }
      
      final accountCredentials = ServiceAccountCredentials.fromJson(_serviceAccountConfig!);
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      
      client.close();
      return accessToken;
    } catch (e) {
      log('❌ Error getting access token: $e');
      return null;
    }
  }
  
  /// Send notification using FCM HTTP v1 API
  Future<bool> _sendNotificationWithData({
    required String fcmToken,
    required NotificationData notificationData,
  }) async {
    try {
      log('📱 Attempting to send notification via FCM HTTP v1...');
      log('📱 FCM Token: ${fcmToken.substring(0, 20)}...');
      
      // Get OAuth2 access token
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        log('❌ Failed to get access token');
        return false;
      }
      
      final fcmPayload = notificationData.toFCMPayload();
      log('📱 Payload: ${jsonEncode(fcmPayload)}');
      
      // Construct FCM HTTP v1 message format
      final requestBody = {
        'message': {
          'token': fcmToken,
          'notification': fcmPayload['notification'],
          'data': (fcmPayload['data'] as Map<String, dynamic>?)?.map<String, String>(
            (String key, dynamic value) => MapEntry(key, value.toString()),
          ) ?? <String, String>{},
          'android': {
            'priority': 'high',
            'notification': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          'apns': {
            'payload': {
              'aps': {
                'content-available': 1,
              },
            },
          },
        },
      };
      
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      log('📱 FCM Response Status: ${response.statusCode}');
      log('📱 FCM Response Body: ${response.body}');

      if (response.statusCode == 200) {
        log('✅ Notification sent successfully via FCM HTTP v1');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        log('❌ FCM HTTP v1 Error: ${errorData['error']?['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      log('❌ Exception sending notification: $e');
      return false;
    }
  }

  /// Store notification history in Firestore
  Future<void> _storeNotificationHistory(
    String userId, 
    NotificationData notificationData
  ) async {
    try {
      final notificationHistory = NotificationHistory(
        userId: userId,
        notificationData: notificationData,
        sentAt: DateTime.now(),
      );

      await _firestore
          .collection('notifications')
          .add(notificationHistory.toFirestore());
      
      log('Notification history stored successfully');
    } catch (e) {
      log('Error storing notification history: $e');
    }
  }

  /// Get notification history for a user
  Future<List<NotificationHistory>> getNotificationHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationHistory.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error getting notification history: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      log('Error marking notification as read: $e');
      return false;
    }
  }

  /// Debug method to test notification system
  Future<void> debugNotificationSystem(String userId) async {
    log('🐛 === NOTIFICATION DEBUG START ===');
    
    // 1. Check if FCM is initialized
    log('🐛 1. Checking FCM initialization...');
    try {
      final token = await getToken();
      log('🐛 Current device FCM token: ${token?.substring(0, 20)}...');
    } catch (e) {
      log('🐛 ❌ FCM initialization error: $e');
    }
    
    // 2. Check user's stored FCM token
    log('🐛 2. Checking stored FCM token...');
    final storedToken = await getUserFCMToken(userId);
    if (storedToken != null) {
      log('🐛 ✅ Stored FCM token found');
    } else {
      log('🐛 ❌ No stored FCM token found');
    }
    
    // 3. Check service account configuration
    log('🐛 3. Checking service account configuration...');
    
    final configLoaded = await _loadServiceAccountConfig();
    if (!configLoaded || _serviceAccountConfig == null) {
      log('🐛 ❌ Service account configuration not loaded!');
      log('🐛 📋 To fix: Create assets/config/service_account.json');
      log('🐛 📋 Go to Firebase Console > Project Settings > Service Accounts');
      log('🐛 📋 Generate a new private key and save it as service_account.json');
    } else if (_serviceAccountConfig!['private_key'] == 'YOUR_PRIVATE_KEY') {
      log('🐛 ❌ Service account credentials not configured!');
      log('🐛 📋 Please update assets/config/service_account.json with real credentials');
    } else {
      log('🐛 ✅ Service account credentials are configured');
      
      // Test access token generation
      final accessToken = await _getAccessToken();
      if (accessToken != null) {
        log('🐛 ✅ Access token generated successfully');
      } else {
        log('🐛 ❌ Failed to generate access token');
      }
    }
    
    // 4. Test notification permissions
    log('🐛 4. Checking notification permissions...');
    final settings = await _firebaseMessaging.getNotificationSettings();
    log('🐛 Permission status: ${settings.authorizationStatus}');
    log('🐛 Alert permission: ${settings.alert}');
    log('🐛 Badge permission: ${settings.badge}');
    log('🐛 Sound permission: ${settings.sound}');
    
    log('🐛 === NOTIFICATION DEBUG END ===');
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  /// Send notification to specific user by FCM token (HTTP v1)
  Future<bool> sendNotificationToUser({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        log('❌ Failed to get access token');
        return false;
      }
      
      final requestBody = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data?.map<String, String>(
            (String key, dynamic value) => MapEntry(key, value.toString()),
          ) ?? <String, String>{},
          'android': {
            'priority': 'high',
            'notification': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
        },
      };
      
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        log('Notification sent successfully');
        return true;
      } else {
        log('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error sending notification: $e');
      return false;
    }
  }

  /// Send notification to topic (HTTP v1)
  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        log('❌ Failed to get access token');
        return false;
      }
      
      final requestBody = {
        'message': {
          'topic': topic,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': data?.map<String, String>(
            (String key, dynamic value) => MapEntry(key, value.toString()),
          ) ?? <String, String>{},
          'android': {
            'priority': 'high',
            'notification': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
        },
      };
      
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        log('Notification sent to topic successfully');
        return true;
      } else {
        log('Failed to send notification to topic: ${response.body}');
        return false;
      }
    } catch (e) {
      log('Error sending notification to topic: $e');
      return false;
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'visitor_management_channel',
      'Visitor Management',
      channelDescription: 'Notifications for visitor management app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');
      
      // Show local notification when app is in foreground
      showLocalNotification(
        id: message.hashCode,
        title: message.notification?.title ?? 'Visitor Management',
        body: message.notification?.body ?? 'You have a new notification',
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    log('Notification tapped with data: ${message.data}');
    _navigateBasedOnNotification(message.data);
  }

  /// Handle notification tap from local notifications
  void _onNotificationTapped(NotificationResponse response) {
    log('Local notification tapped with payload: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        log('Notification data: $data');
        _navigateBasedOnNotification(data);
      } catch (e) {
        log('Error parsing notification payload: $e');
      }
    }
  }
  
  /// Navigate based on notification data
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    if (_navigatorKey?.currentState == null) {
      log('Navigator not available for notification navigation');
      return;
    }
    
    final context = _navigatorKey!.currentState!.context;
    final action = data['action'] as String?;
    
    switch (action) {
      case 'visitor_arrival':
        _navigateToVisitorDetails(context, data);
        break;
      case 'visitor_approved':
      case 'visitor_rejected':
        _navigateToVisitorHistory(context, data);
        break;
      default:
        log('Unknown notification action: $action');
        _navigateToDefaultScreen(context);
    }
  }
  
  /// Navigate to visitor details screen
  void _navigateToVisitorDetails(BuildContext context, Map<String, dynamic> data) {
    try {
      // Navigate to visitor details or dashboard
      // This depends on your app's navigation structure
      _navigatorKey!.currentState!.pushNamed(
        '/dashboard', // Replace with your visitor details route
        arguments: {
          'visitorId': data['visitorId'],
          'action': 'visitor_arrival',
        },
      );
    } catch (e) {
      log('Error navigating to visitor details: $e');
      _navigateToDefaultScreen(context);
    }
  }
  
  /// Navigate to visitor history screen
  void _navigateToVisitorHistory(BuildContext context, Map<String, dynamic> data) {
    try {
      _navigatorKey!.currentState!.pushNamed(
        '/visitor-history', // Replace with your visitor history route
        arguments: {
          'visitorId': data['visitorId'],
          'action': data['action'],
        },
      );
    } catch (e) {
      log('Error navigating to visitor history: $e');
      _navigateToDefaultScreen(context);
    }
  }
  
  /// Navigate to default screen (dashboard)
  void _navigateToDefaultScreen(BuildContext context) {
    try {
      _navigatorKey!.currentState!.pushNamedAndRemoveUntil(
        '/dashboard', // Replace with your main dashboard route
        (route) => false,
      );
    } catch (e) {
      log('Error navigating to default screen: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
  // Handle background notification here
}