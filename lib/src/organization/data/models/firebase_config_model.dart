import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/organization/domain/entities/firebase_config.dart';

/// Data model for FirebaseConfig with serialization
class FirebaseConfigModel extends FirebaseConfig {
  const FirebaseConfigModel({
    super.android,
    super.ios,
  });

  /// Creates empty Firebase config model
  const FirebaseConfigModel.empty() : super.empty();

  /// Creates a model from an entity
  factory FirebaseConfigModel.fromEntity(FirebaseConfig entity) {
    return FirebaseConfigModel(
      android: entity.android != null
          ? FirebasePlatformConfigModel.fromEntity(entity.android!)
          : null,
      ios: entity.ios != null
          ? FirebasePlatformConfigModel.fromEntity(entity.ios!)
          : null,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory FirebaseConfigModel.fromJson(DataMap json) {
    return FirebaseConfigModel(
      android: json['android'] != null
          ? FirebasePlatformConfigModel.fromJson(
              json['android'] as DataMap,
            )
          : null,
      ios: json['ios'] != null
          ? FirebasePlatformConfigModel.fromJson(
              json['ios'] as DataMap,
            )
          : null,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      if (android != null)
        'android': (android as FirebasePlatformConfigModel).toJson(),
      if (ios != null) 'ios': (ios as FirebasePlatformConfigModel).toJson(),
    };
  }
}

/// Data model for FirebasePlatformConfig with serialization
class FirebasePlatformConfigModel extends FirebasePlatformConfig {
  const FirebasePlatformConfigModel({
    required super.apiKey,
    required super.appId,
    required super.messagingSenderId,
    required super.projectId,
    required super.storageBucket,
    super.iosBundleId,
    super.iosClientId,
    super.databaseUrl,
  });

  /// Creates empty platform config model
  const FirebasePlatformConfigModel.empty() : super.empty();

  /// Creates a model from an entity
  factory FirebasePlatformConfigModel.fromEntity(
      FirebasePlatformConfig entity) {
    return FirebasePlatformConfigModel(
      apiKey: entity.apiKey,
      appId: entity.appId,
      messagingSenderId: entity.messagingSenderId,
      projectId: entity.projectId,
      storageBucket: entity.storageBucket,
      iosBundleId: entity.iosBundleId,
      iosClientId: entity.iosClientId,
      databaseUrl: entity.databaseUrl,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory FirebasePlatformConfigModel.fromJson(DataMap json) {
    return FirebasePlatformConfigModel(
      apiKey: json['apiKey'] as String? ?? '',
      appId: json['appId'] as String? ?? '',
      messagingSenderId: json['messagingSenderId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      storageBucket: json['storageBucket'] as String? ?? '',
      iosBundleId: json['iosBundleId'] as String?,
      iosClientId: json['iosClientId'] as String?,
      databaseUrl: json['databaseUrl'] as String?,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      'apiKey': apiKey,
      'appId': appId,
      'messagingSenderId': messagingSenderId,
      'projectId': projectId,
      'storageBucket': storageBucket,
      if (iosBundleId != null) 'iosBundleId': iosBundleId,
      if (iosClientId != null) 'iosClientId': iosClientId,
      if (databaseUrl != null) 'databaseUrl': databaseUrl,
    };
  }
}
