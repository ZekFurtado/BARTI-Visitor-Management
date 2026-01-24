import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/organization/data/models/branding_config_model.dart';
import 'package:visitor_management/src/organization/data/models/custom_field_model.dart';
import 'package:visitor_management/src/organization/data/models/feature_config_model.dart';
import 'package:visitor_management/src/organization/data/models/firebase_config_model.dart';
import 'package:visitor_management/src/organization/domain/entities/branding_config.dart';
import 'package:visitor_management/src/organization/domain/entities/custom_field.dart';
import 'package:visitor_management/src/organization/domain/entities/feature_config.dart';
import 'package:visitor_management/src/organization/domain/entities/firebase_config.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';

/// Data model for Organization with Firebase serialization
class OrganizationModel extends Organization {
  const OrganizationModel({
    required super.id,
    required super.subdomain,
    required super.name,
    required super.status,
    required super.firebaseConfig,
    required super.branding,
    required super.features,
    super.visitorCustomFields,
    super.employeeCustomFields,
    super.address,
    super.phone,
    super.email,
    super.website,
    required super.createdAt,
    super.updatedAt,
    super.subscriptionPlan,
    super.trialEndsAt,
    super.metadata,
  });

  /// Creates empty organization model
  OrganizationModel.empty() : super.empty();

  /// Creates a model from an entity
  factory OrganizationModel.fromEntity(Organization entity) {
    return OrganizationModel(
      id: entity.id,
      subdomain: entity.subdomain,
      name: entity.name,
      status: entity.status,
      firebaseConfig: FirebaseConfigModel.fromEntity(entity.firebaseConfig),
      branding: BrandingConfigModel.fromEntity(entity.branding),
      features: FeatureConfigModel.fromEntity(entity.features),
      visitorCustomFields: entity.visitorCustomFields
          .map((field) => CustomFieldModel.fromEntity(field))
          .toList(),
      employeeCustomFields: entity.employeeCustomFields
          .map((field) => CustomFieldModel.fromEntity(field))
          .toList(),
      address: entity.address,
      phone: entity.phone,
      email: entity.email,
      website: entity.website,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      subscriptionPlan: entity.subscriptionPlan,
      trialEndsAt: entity.trialEndsAt,
      metadata: entity.metadata,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory OrganizationModel.fromJson(DataMap json) {
    return OrganizationModel(
      id: json['id'] as String? ?? '',
      subdomain: json['subdomain'] as String? ?? '',
      name: json['name'] as String? ?? '',
      status: OrganizationStatusX.fromJson(
        json['status'] as String? ?? 'inactive',
      ),
      firebaseConfig: json['firebaseConfig'] != null
          ? FirebaseConfigModel.fromJson(json['firebaseConfig'] as DataMap)
          : const FirebaseConfigModel.empty(),
      branding: json['branding'] != null
          ? BrandingConfigModel.fromJson(json['branding'] as DataMap)
          : const BrandingConfigModel.defaultBranding(),
      features: json['features'] != null
          ? FeatureConfigModel.fromJson(json['features'] as DataMap)
          : const FeatureConfigModel.freeTier(),
      visitorCustomFields: json['visitorCustomFields'] != null
          ? (json['visitorCustomFields'] as List)
                .map((field) => CustomFieldModel.fromJson(field as DataMap))
                .toList()
          : const [],
      employeeCustomFields: json['employeeCustomFields'] != null
          ? (json['employeeCustomFields'] as List)
                .map((field) => CustomFieldModel.fromJson(field as DataMap))
                .toList()
          : const [],
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      subscriptionPlan: json['subscriptionPlan'] != null
          ? SubscriptionPlanX.fromJson(json['subscriptionPlan'] as String)
          : null,
      trialEndsAt: json['trialEndsAt'] != null
          ? (json['trialEndsAt'] as Timestamp).toDate()
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      'id': id,
      'subdomain': subdomain,
      'name': name,
      'status': status.toJson(),
      'firebaseConfig': (firebaseConfig as FirebaseConfigModel).toJson(),
      'branding': (branding as BrandingConfigModel).toJson(),
      'features': (features as FeatureConfigModel).toJson(),
      if (visitorCustomFields.isNotEmpty)
        'visitorCustomFields': visitorCustomFields
            .map((field) => (field as CustomFieldModel).toJson())
            .toList(),
      if (employeeCustomFields.isNotEmpty)
        'employeeCustomFields': employeeCustomFields
            .map((field) => (field as CustomFieldModel).toJson())
            .toList(),
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (subscriptionPlan != null)
        'subscriptionPlan': subscriptionPlan!.toJson(),
      if (trialEndsAt != null) 'trialEndsAt': Timestamp.fromDate(trialEndsAt!),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Copy with method
  @override
  OrganizationModel copyWith({
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
    return OrganizationModel(
      id: id ?? this.id,
      subdomain: subdomain ?? this.subdomain,
      name: name ?? this.name,
      status: status ?? this.status,
      firebaseConfig:
          (firebaseConfig ?? this.firebaseConfig) as FirebaseConfigModel,
      branding: (branding ?? this.branding) as BrandingConfigModel,
      features: (features ?? this.features) as FeatureConfigModel,
      visitorCustomFields:
          (visitorCustomFields ?? this.visitorCustomFields).cast<CustomFieldModel>(),
      employeeCustomFields:
          (employeeCustomFields ?? this.employeeCustomFields).cast<CustomFieldModel>(),
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
}
