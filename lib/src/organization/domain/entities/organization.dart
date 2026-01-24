import 'package:equatable/equatable.dart';
import 'package:visitor_management/src/organization/domain/entities/branding_config.dart';
import 'package:visitor_management/src/organization/domain/entities/custom_field.dart';
import 'package:visitor_management/src/organization/domain/entities/feature_config.dart';
import 'package:visitor_management/src/organization/domain/entities/firebase_config.dart';

/// Represents an organization/tenant in the multi-tenant system
/// Each organization has its own Firebase project, branding, and feature set
class Organization extends Equatable {
  /// Unique identifier for this organization
  final String id;

  /// Subdomain for this organization (e.g., "barti" for barti.epravesh.com)
  final String subdomain;

  /// Organization display name
  final String name;

  /// Organization status
  final OrganizationStatus status;

  /// Firebase configuration for this organization
  final FirebaseConfig firebaseConfig;

  /// Branding configuration (colors, logo, app name)
  final BrandingConfig branding;

  /// Feature configuration (enabled/disabled features)
  final FeatureConfig features;

  /// Custom fields for visitors
  final List<CustomField> visitorCustomFields;

  /// Custom fields for employees
  final List<CustomField> employeeCustomFields;

  /// Organization address
  final String? address;

  /// Organization phone number
  final String? phone;

  /// Organization email
  final String? email;

  /// Organization website
  final String? website;

  /// When the organization was created
  final DateTime createdAt;

  /// When the organization was last updated
  final DateTime? updatedAt;

  /// Subscription plan
  final SubscriptionPlan? subscriptionPlan;

  /// Trial end date (if applicable)
  final DateTime? trialEndsAt;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const Organization({
    required this.id,
    required this.subdomain,
    required this.name,
    required this.status,
    required this.firebaseConfig,
    required this.branding,
    required this.features,
    this.visitorCustomFields = const [],
    this.employeeCustomFields = const [],
    this.address,
    this.phone,
    this.email,
    this.website,
    required this.createdAt,
    this.updatedAt,
    this.subscriptionPlan,
    this.trialEndsAt,
    this.metadata,
  });

  /// Creates an empty organization
  Organization.empty()
      : id = '',
        subdomain = '',
        name = '',
        status = OrganizationStatus.inactive,
        firebaseConfig = const FirebaseConfig.empty(),
        branding = const BrandingConfig.empty(),
        features = const FeatureConfig.empty(),
        visitorCustomFields = const [],
        employeeCustomFields = const [],
        address = null,
        phone = null,
        email = null,
        website = null,
        createdAt = DateTime.now(),
        updatedAt = null,
        subscriptionPlan = null,
        trialEndsAt = null,
        metadata = null;

  /// Check if a specific feature is enabled
  bool isFeatureEnabled(String featureName) {
    return features.isFeatureEnabled(featureName);
  }

  /// Check if organization is active
  bool get isActive => status == OrganizationStatus.active;

  /// Check if organization is on trial
  bool get isOnTrial => status == OrganizationStatus.trial &&
      trialEndsAt != null &&
      trialEndsAt!.isAfter(DateTime.now());

  /// Check if trial has expired
  bool get isTrialExpired => status == OrganizationStatus.trial &&
      trialEndsAt != null &&
      trialEndsAt!.isBefore(DateTime.now());

  /// Check if organization is suspended
  bool get isSuspended => status == OrganizationStatus.suspended;

  /// Get custom field by ID for visitors
  CustomField? getVisitorCustomField(String fieldId) {
    try {
      return visitorCustomFields.firstWhere((field) => field.id == fieldId);
    } catch (e) {
      return null;
    }
  }

  /// Get custom field by ID for employees
  CustomField? getEmployeeCustomField(String fieldId) {
    try {
      return employeeCustomFields.firstWhere((field) => field.id == fieldId);
    } catch (e) {
      return null;
    }
  }

  /// Check if organization can add more employees
  bool canAddEmployee(int currentEmployeeCount) {
    return features.canAddEmployee(currentEmployeeCount);
  }

  /// Check if organization can add more gatekeepers
  bool canAddGatekeeper(int currentGatekeeperCount) {
    return features.canAddGatekeeper(currentGatekeeperCount);
  }

  /// Copy with method for creating modified organizations
  Organization copyWith({
    String? id,
    String? subdomain,
    String? name,
    OrganizationStatus? status,
    FirebaseConfig? firebaseConfig,
    BrandingConfig? branding,
    FeatureConfig? features,
    List<CustomField>? visitorCustomFields,
    List<CustomField>? employeeCustomFields,
    String? address,
    String? phone,
    String? email,
    String? website,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubscriptionPlan? subscriptionPlan,
    DateTime? trialEndsAt,
    Map<String, dynamic>? metadata,
  }) {
    return Organization(
      id: id ?? this.id,
      subdomain: subdomain ?? this.subdomain,
      name: name ?? this.name,
      status: status ?? this.status,
      firebaseConfig: firebaseConfig ?? this.firebaseConfig,
      branding: branding ?? this.branding,
      features: features ?? this.features,
      visitorCustomFields: visitorCustomFields ?? this.visitorCustomFields,
      employeeCustomFields: employeeCustomFields ?? this.employeeCustomFields,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subdomain,
        name,
        status,
        firebaseConfig,
        branding,
        features,
        visitorCustomFields,
        employeeCustomFields,
        address,
        phone,
        email,
        website,
        createdAt,
        updatedAt,
        subscriptionPlan,
        trialEndsAt,
        metadata,
      ];

  @override
  String toString() {
    return 'Organization(id: $id, name: $name, subdomain: $subdomain, status: $status)';
  }
}

/// Organization status enumeration
enum OrganizationStatus {
  /// Organization is active and operational
  active,

  /// Organization is on trial period
  trial,

  /// Organization is suspended (payment issue, violation, etc.)
  suspended,

  /// Organization is inactive (not in use)
  inactive,

  /// Organization is pending setup/approval
  pending,
}

/// Extension methods for OrganizationStatus
extension OrganizationStatusX on OrganizationStatus {
  /// Get display name for status
  String get displayName {
    switch (this) {
      case OrganizationStatus.active:
        return 'Active';
      case OrganizationStatus.trial:
        return 'Trial';
      case OrganizationStatus.suspended:
        return 'Suspended';
      case OrganizationStatus.inactive:
        return 'Inactive';
      case OrganizationStatus.pending:
        return 'Pending';
    }
  }

  /// Convert to string for serialization
  String toJson() => name;

  /// Parse from string
  static OrganizationStatus fromJson(String value) {
    return OrganizationStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => OrganizationStatus.inactive,
    );
  }
}

/// Subscription plan enumeration
enum SubscriptionPlan {
  /// Free tier with limited features
  free,

  /// Basic tier with standard features
  basic,

  /// Premium tier with advanced features
  premium,

  /// Enterprise tier with all features
  enterprise,

  /// Custom plan negotiated separately
  custom,
}

/// Extension methods for SubscriptionPlan
extension SubscriptionPlanX on SubscriptionPlan {
  /// Get display name for plan
  String get displayName {
    switch (this) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
      case SubscriptionPlan.custom:
        return 'Custom';
    }
  }

  /// Convert to string for serialization
  String toJson() => name;

  /// Parse from string
  static SubscriptionPlan fromJson(String value) {
    return SubscriptionPlan.values.firstWhere(
      (plan) => plan.name == value,
      orElse: () => SubscriptionPlan.free,
    );
  }
}
