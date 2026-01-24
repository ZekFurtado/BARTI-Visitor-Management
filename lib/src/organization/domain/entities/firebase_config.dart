import 'package:equatable/equatable.dart';

/// Firebase project configuration for an organization
/// Contains platform-specific Firebase credentials
class FirebaseConfig extends Equatable {
  /// Android platform configuration
  final FirebasePlatformConfig? android;

  /// iOS platform configuration
  final FirebasePlatformConfig? ios;

  const FirebaseConfig({
    this.android,
    this.ios,
  });

  /// Creates an empty Firebase configuration
  const FirebaseConfig.empty()
      : android = null,
        ios = null;

  @override
  List<Object?> get props => [android, ios];

  @override
  String toString() {
    return 'FirebaseConfig(android: ${android != null}, ios: ${ios != null})';
  }
}

/// Platform-specific Firebase configuration (Android or iOS)
class FirebasePlatformConfig extends Equatable {
  /// Firebase API key
  final String apiKey;

  /// Firebase App ID
  final String appId;

  /// Firebase Messaging Sender ID
  final String messagingSenderId;

  /// Firebase Project ID
  final String projectId;

  /// Firebase Storage Bucket
  final String storageBucket;

  /// iOS Bundle ID (iOS only)
  final String? iosBundleId;

  /// iOS Client ID (iOS only, for Google Sign-In)
  final String? iosClientId;

  /// Database URL (optional, for Realtime Database)
  final String? databaseUrl;

  const FirebasePlatformConfig({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.storageBucket,
    this.iosBundleId,
    this.iosClientId,
    this.databaseUrl,
  });

  /// Creates an empty platform configuration
  const FirebasePlatformConfig.empty()
      : apiKey = '',
        appId = '',
        messagingSenderId = '',
        projectId = '',
        storageBucket = '',
        iosBundleId = null,
        iosClientId = null,
        databaseUrl = null;

  @override
  List<Object?> get props => [
        apiKey,
        appId,
        messagingSenderId,
        projectId,
        storageBucket,
        iosBundleId,
        iosClientId,
        databaseUrl,
      ];

  @override
  String toString() {
    return 'FirebasePlatformConfig(projectId: $projectId, appId: $appId)';
  }
}
