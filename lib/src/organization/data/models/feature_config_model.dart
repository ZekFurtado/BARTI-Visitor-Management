import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/organization/domain/entities/feature_config.dart';

/// Data model for FeatureConfig with Firebase serialization
class FeatureConfigModel extends FeatureConfig {
  const FeatureConfigModel({
    required super.visitorPhotos,
    required super.smsNotifications,
    required super.emailNotifications,
    required super.visitorHistory,
    required super.customFields,
    required super.ssoEnabled,
    required super.maxEmployees,
    required super.maxGatekeepers,
    super.qrCodeEnabled,
    super.checkInOutEnabled,
    super.analyticsEnabled,
    super.exportEnabled,
    super.apiAccessEnabled,
    super.customBrandingEnabled,
  });

  /// Creates empty feature config model
  const FeatureConfigModel.empty() : super.empty();

  /// Creates free tier feature config model
  const FeatureConfigModel.freeTier() : super.freeTier();

  /// Creates basic tier feature config model
  const FeatureConfigModel.basicTier() : super.basicTier();

  /// Creates premium tier feature config model
  const FeatureConfigModel.premiumTier() : super.premiumTier();

  /// Creates enterprise tier feature config model
  const FeatureConfigModel.enterpriseTier() : super.enterpriseTier();

  /// Creates a model from an entity
  factory FeatureConfigModel.fromEntity(FeatureConfig entity) {
    return FeatureConfigModel(
      visitorPhotos: entity.visitorPhotos,
      smsNotifications: entity.smsNotifications,
      emailNotifications: entity.emailNotifications,
      visitorHistory: entity.visitorHistory,
      customFields: entity.customFields,
      ssoEnabled: entity.ssoEnabled,
      maxEmployees: entity.maxEmployees,
      maxGatekeepers: entity.maxGatekeepers,
      qrCodeEnabled: entity.qrCodeEnabled,
      checkInOutEnabled: entity.checkInOutEnabled,
      analyticsEnabled: entity.analyticsEnabled,
      exportEnabled: entity.exportEnabled,
      apiAccessEnabled: entity.apiAccessEnabled,
      customBrandingEnabled: entity.customBrandingEnabled,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory FeatureConfigModel.fromJson(DataMap json) {
    return FeatureConfigModel(
      visitorPhotos: json['visitorPhotos'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? false,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      visitorHistory: json['visitorHistory'] as bool? ?? true,
      customFields: json['customFields'] as bool? ?? false,
      ssoEnabled: json['ssoEnabled'] as bool? ?? false,
      maxEmployees: json['maxEmployees'] as int? ?? 10,
      maxGatekeepers: json['maxGatekeepers'] as int? ?? 2,
      qrCodeEnabled: json['qrCodeEnabled'] as bool? ?? true,
      checkInOutEnabled: json['checkInOutEnabled'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? false,
      exportEnabled: json['exportEnabled'] as bool? ?? false,
      apiAccessEnabled: json['apiAccessEnabled'] as bool? ?? false,
      customBrandingEnabled: json['customBrandingEnabled'] as bool? ?? false,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      'visitorPhotos': visitorPhotos,
      'smsNotifications': smsNotifications,
      'emailNotifications': emailNotifications,
      'visitorHistory': visitorHistory,
      'customFields': customFields,
      'ssoEnabled': ssoEnabled,
      'maxEmployees': maxEmployees,
      'maxGatekeepers': maxGatekeepers,
      'qrCodeEnabled': qrCodeEnabled,
      'checkInOutEnabled': checkInOutEnabled,
      'analyticsEnabled': analyticsEnabled,
      'exportEnabled': exportEnabled,
      'apiAccessEnabled': apiAccessEnabled,
      'customBrandingEnabled': customBrandingEnabled,
    };
  }

  /// Copy with method
  FeatureConfigModel copyWith({
    bool? visitorPhotos,
    bool? smsNotifications,
    bool? emailNotifications,
    bool? visitorHistory,
    bool? customFields,
    bool? ssoEnabled,
    int? maxEmployees,
    int? maxGatekeepers,
    bool? qrCodeEnabled,
    bool? checkInOutEnabled,
    bool? analyticsEnabled,
    bool? exportEnabled,
    bool? apiAccessEnabled,
    bool? customBrandingEnabled,
  }) {
    return FeatureConfigModel(
      visitorPhotos: visitorPhotos ?? this.visitorPhotos,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      visitorHistory: visitorHistory ?? this.visitorHistory,
      customFields: customFields ?? this.customFields,
      ssoEnabled: ssoEnabled ?? this.ssoEnabled,
      maxEmployees: maxEmployees ?? this.maxEmployees,
      maxGatekeepers: maxGatekeepers ?? this.maxGatekeepers,
      qrCodeEnabled: qrCodeEnabled ?? this.qrCodeEnabled,
      checkInOutEnabled: checkInOutEnabled ?? this.checkInOutEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      exportEnabled: exportEnabled ?? this.exportEnabled,
      apiAccessEnabled: apiAccessEnabled ?? this.apiAccessEnabled,
      customBrandingEnabled: customBrandingEnabled ?? this.customBrandingEnabled,
    );
  }
}
