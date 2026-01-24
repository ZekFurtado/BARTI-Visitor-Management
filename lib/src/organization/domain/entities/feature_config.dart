import 'package:equatable/equatable.dart';

/// Configuration of features available to an organization
/// Controls which features are enabled/disabled based on subscription plan
class FeatureConfig extends Equatable {
  /// Whether visitor photo capture is enabled
  final bool visitorPhotos;

  /// Whether SMS notifications are enabled
  final bool smsNotifications;

  /// Whether email notifications are enabled
  final bool emailNotifications;

  /// Whether visitor history tracking is enabled
  final bool visitorHistory;

  /// Whether custom fields are enabled
  final bool customFields;

  /// Whether SSO (Single Sign-On) is enabled
  final bool ssoEnabled;

  /// Maximum number of employees allowed
  final int maxEmployees;

  /// Maximum number of gatekeepers allowed
  final int maxGatekeepers;

  /// Whether QR code generation is enabled
  final bool qrCodeEnabled;

  /// Whether visitor check-in/check-out is enabled
  final bool checkInOutEnabled;

  /// Whether dashboard analytics are enabled
  final bool analyticsEnabled;

  /// Whether export functionality is enabled
  final bool exportEnabled;

  /// Whether API access is enabled
  final bool apiAccessEnabled;

  /// Whether custom branding is enabled
  final bool customBrandingEnabled;

  const FeatureConfig({
    required this.visitorPhotos,
    required this.smsNotifications,
    required this.emailNotifications,
    required this.visitorHistory,
    required this.customFields,
    required this.ssoEnabled,
    required this.maxEmployees,
    required this.maxGatekeepers,
    this.qrCodeEnabled = true,
    this.checkInOutEnabled = true,
    this.analyticsEnabled = true,
    this.exportEnabled = false,
    this.apiAccessEnabled = false,
    this.customBrandingEnabled = false,
  });

  /// Free tier feature configuration
  const FeatureConfig.freeTier()
      : visitorPhotos = true,
        smsNotifications = false,
        emailNotifications = true,
        visitorHistory = true,
        customFields = false,
        ssoEnabled = false,
        maxEmployees = 10,
        maxGatekeepers = 2,
        qrCodeEnabled = true,
        checkInOutEnabled = true,
        analyticsEnabled = false,
        exportEnabled = false,
        apiAccessEnabled = false,
        customBrandingEnabled = false;

  /// Basic tier feature configuration
  const FeatureConfig.basicTier()
      : visitorPhotos = true,
        smsNotifications = true,
        emailNotifications = true,
        visitorHistory = true,
        customFields = true,
        ssoEnabled = false,
        maxEmployees = 50,
        maxGatekeepers = 5,
        qrCodeEnabled = true,
        checkInOutEnabled = true,
        analyticsEnabled = true,
        exportEnabled = true,
        apiAccessEnabled = false,
        customBrandingEnabled = false;

  /// Premium tier feature configuration
  const FeatureConfig.premiumTier()
      : visitorPhotos = true,
        smsNotifications = true,
        emailNotifications = true,
        visitorHistory = true,
        customFields = true,
        ssoEnabled = true,
        maxEmployees = 200,
        maxGatekeepers = 10,
        qrCodeEnabled = true,
        checkInOutEnabled = true,
        analyticsEnabled = true,
        exportEnabled = true,
        apiAccessEnabled = true,
        customBrandingEnabled = true;

  /// Enterprise tier feature configuration (unlimited)
  const FeatureConfig.enterpriseTier()
      : visitorPhotos = true,
        smsNotifications = true,
        emailNotifications = true,
        visitorHistory = true,
        customFields = true,
        ssoEnabled = true,
        maxEmployees = 999999,
        maxGatekeepers = 100,
        qrCodeEnabled = true,
        checkInOutEnabled = true,
        analyticsEnabled = true,
        exportEnabled = true,
        apiAccessEnabled = true,
        customBrandingEnabled = true;

  /// Empty configuration (all features disabled)
  const FeatureConfig.empty()
      : visitorPhotos = false,
        smsNotifications = false,
        emailNotifications = false,
        visitorHistory = false,
        customFields = false,
        ssoEnabled = false,
        maxEmployees = 0,
        maxGatekeepers = 0,
        qrCodeEnabled = false,
        checkInOutEnabled = false,
        analyticsEnabled = false,
        exportEnabled = false,
        apiAccessEnabled = false,
        customBrandingEnabled = false;

  /// Check if a specific feature is enabled by name
  bool isFeatureEnabled(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'visitorphotos':
      case 'visitor_photos':
        return visitorPhotos;
      case 'smsnotifications':
      case 'sms_notifications':
        return smsNotifications;
      case 'emailnotifications':
      case 'email_notifications':
        return emailNotifications;
      case 'visitorhistory':
      case 'visitor_history':
        return visitorHistory;
      case 'customfields':
      case 'custom_fields':
        return customFields;
      case 'sso':
      case 'ssoenabled':
      case 'sso_enabled':
        return ssoEnabled;
      case 'qrcode':
      case 'qr_code':
        return qrCodeEnabled;
      case 'checkinout':
      case 'check_in_out':
        return checkInOutEnabled;
      case 'analytics':
        return analyticsEnabled;
      case 'export':
        return exportEnabled;
      case 'api':
      case 'apiaccess':
      case 'api_access':
        return apiAccessEnabled;
      case 'custombranding':
      case 'custom_branding':
        return customBrandingEnabled;
      default:
        return false;
    }
  }

  /// Check if employee limit has been reached
  bool canAddEmployee(int currentEmployeeCount) {
    return currentEmployeeCount < maxEmployees;
  }

  /// Check if gatekeeper limit has been reached
  bool canAddGatekeeper(int currentGatekeeperCount) {
    return currentGatekeeperCount < maxGatekeepers;
  }

  /// Get remaining employee slots
  int getRemainingEmployeeSlots(int currentEmployeeCount) {
    final remaining = maxEmployees - currentEmployeeCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Get remaining gatekeeper slots
  int getRemainingGatekeeperSlots(int currentGatekeeperCount) {
    final remaining = maxGatekeepers - currentGatekeeperCount;
    return remaining > 0 ? remaining : 0;
  }

  /// Copy with method for creating modified configurations
  FeatureConfig copyWith({
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
    return FeatureConfig(
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

  @override
  List<Object?> get props => [
        visitorPhotos,
        smsNotifications,
        emailNotifications,
        visitorHistory,
        customFields,
        ssoEnabled,
        maxEmployees,
        maxGatekeepers,
        qrCodeEnabled,
        checkInOutEnabled,
        analyticsEnabled,
        exportEnabled,
        apiAccessEnabled,
        customBrandingEnabled,
      ];

  @override
  String toString() {
    return 'FeatureConfig(visitorPhotos: $visitorPhotos, customFields: $customFields, '
        'maxEmployees: $maxEmployees, maxGatekeepers: $maxGatekeepers)';
  }
}
