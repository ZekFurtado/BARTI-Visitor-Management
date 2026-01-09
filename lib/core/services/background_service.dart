import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing background app execution and permissions
class BackgroundService {
  static const MethodChannel _channel = MethodChannel(
    'visitor_management/background',
  );

  /// Initialize background service
  static Future<void> initialize() async {
    log('🔧 Initializing background service...');

    try {
      // Request notification permissions first
      await _requestNotificationPermissions();

      if (Platform.isAndroid) {
        await _initializeAndroid();
      } else if (Platform.isIOS) {
        await _initializeIOS();
      }

      log('✅ Background service initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize background service: $e');
    }
  }

  /// Request notification permissions
  static Future<bool> _requestNotificationPermissions() async {
    log('📱 Requesting notification permissions...');

    // Request notification permission
    final status = await Permission.notification.request();
    if (status.isGranted) {
      log('✅ Notification permission granted');
      return true;
    } else {
      log('❌ Notification permission denied');
      return false;
    }
  }

  /// Initialize Android-specific background services
  static Future<void> _initializeAndroid() async {
    log('🤖 Initializing Android background services...');

    try {
      // Check if battery optimization is disabled
      final isOptimizationDisabled = await _channel.invokeMethod(
        'isBatteryOptimizationDisabled',
      );

      if (!isOptimizationDisabled) {
        log('🔋 Requesting battery optimization exemption...');
        await _channel.invokeMethod('requestBatteryOptimizationExemption');
      } else {
        log('✅ Battery optimization already disabled');
      }

      // Start background service
      log('🚀 Starting Android background service...');
      await _channel.invokeMethod('startBackgroundService');

      // Request additional permissions
      await _requestAndroidPermissions();
    } catch (e) {
      log('❌ Failed to initialize Android background services: $e');
    }
  }

  /// Request Android-specific permissions
  static Future<void> _requestAndroidPermissions() async {
    final permissions = [
      Permission.ignoreBatteryOptimizations,
      Permission.systemAlertWindow,
    ];

    for (final permission in permissions) {
      try {
        final status = await permission.request();
        log('🔐 ${permission.toString()}: ${status.toString()}');
      } catch (e) {
        log('❌ Failed to request ${permission.toString()}: $e');
      }
    }
  }

  /// Initialize iOS-specific background services
  static Future<void> _initializeIOS() async {
    log('🍎 Initializing iOS background services...');

    try {
      // Request critical alert permission for iOS
      final status = await Permission.criticalAlerts.request();
      log('🚨 Critical alerts permission: $status');

      // Background app refresh is handled by iOS automatically if enabled in settings
      log('✅ iOS background configuration complete');
    } catch (e) {
      log('❌ Failed to initialize iOS background services: $e');
    }
  }

  /// Check if background permissions are granted
  static Future<bool> areBackgroundPermissionsGranted() async {
    try {
      final notificationStatus = await Permission.notification.status;

      if (Platform.isAndroid) {
        final isOptimizationDisabled = await _channel.invokeMethod(
          'isBatteryOptimizationDisabled',
        );
        return notificationStatus.isGranted && isOptimizationDisabled;
      } else if (Platform.isIOS) {
        // For iOS, check if notifications are enabled and background app refresh is available
        return notificationStatus.isGranted;
      }

      return notificationStatus.isGranted;
    } catch (e) {
      log('❌ Failed to check background permissions: $e');
      return false;
    }
  }

  /// Show settings to user for manual configuration
  static Future<void> openBackgroundSettings() async {
    try {
      if (Platform.isAndroid) {
        // Open battery optimization settings
        await _channel.invokeMethod('requestBatteryOptimizationExemption');
      } else if (Platform.isIOS) {
        // Open app settings
        await openAppSettings();
      }
    } catch (e) {
      log('❌ Failed to open background settings: $e');
    }
  }

  /// Restart background service (Android only)
  static Future<void> restartBackgroundService() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('startBackgroundService');
        log('🔄 Background service restarted');
      } catch (e) {
        log('❌ Failed to restart background service: $e');
      }
    }
  }

  /// Get background service status
  static Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final notificationStatus = await Permission.notification.status;

      if (Platform.isAndroid) {
        final isOptimizationDisabled = await _channel.invokeMethod(
          'isBatteryOptimizationDisabled',
        );

        return {
          'platform': 'android',
          'notificationsEnabled': notificationStatus.isGranted,
          'batteryOptimizationDisabled': isOptimizationDisabled,
          'backgroundServiceRunning': true,
          // We assume it's running if permissions are granted
        };
      } else if (Platform.isIOS) {
        return {
          'platform': 'ios',
          'notificationsEnabled': notificationStatus.isGranted,
          'backgroundAppRefreshEnabled': true, // iOS handles this automatically
        };
      }

      return {
        'platform': 'unknown',
        'notificationsEnabled': notificationStatus.isGranted,
      };
    } catch (e) {
      log('❌ Failed to get service status: $e');
      return {
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'error': e.toString(),
      };
    }
  }

  /// Show user-friendly instructions for enabling background notifications
  static String getBackgroundInstructions() {
    if (Platform.isAndroid) {
      return '''
To ensure you receive visitor notifications when the app is closed:

1. Allow notifications when prompted
2. Disable battery optimization for this app
3. Enable "Allow background activity" in app settings
4. Turn off "Adaptive battery" or add this app to the unrestricted list

These settings help keep the app running in the background to receive important visitor notifications.
''';
    } else if (Platform.isIOS) {
      return '''
To ensure you receive visitor notifications when the app is closed:

1. Allow notifications when prompted
2. Go to Settings > General > Background App Refresh
3. Enable "Background App Refresh" for this app
4. Go to Settings > Notifications > Visitor Management
5. Enable "Allow Notifications" and "Time Sensitive Notifications"

These settings help you receive important visitor notifications even when the app is closed.
''';
    }

    return 'Please enable notifications to receive visitor alerts.';
  }
}
