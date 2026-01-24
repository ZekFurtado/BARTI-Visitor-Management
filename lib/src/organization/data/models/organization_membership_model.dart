import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/organization/domain/entities/organization_membership.dart';

/// Data model for OrganizationMembership with Firebase serialization
class OrganizationMembershipModel extends OrganizationMembership {
  const OrganizationMembershipModel({
    required super.organizationId,
    required super.organizationName,
    required super.userId,
    required super.role,
    super.jobRole,
    super.department,
    required super.joinedAt,
    super.isActive,
    super.updatedAt,
    super.permissions,
    super.metadata,
  });

  /// Creates empty organization membership model
  OrganizationMembershipModel.empty() : super.empty();

  /// Creates a model from an entity
  factory OrganizationMembershipModel.fromEntity(
      OrganizationMembership entity) {
    return OrganizationMembershipModel(
      organizationId: entity.organizationId,
      organizationName: entity.organizationName,
      userId: entity.userId,
      role: entity.role,
      jobRole: entity.jobRole,
      department: entity.department,
      joinedAt: entity.joinedAt,
      isActive: entity.isActive,
      updatedAt: entity.updatedAt,
      permissions: entity.permissions,
      metadata: entity.metadata,
    );
  }

  /// Creates a model from JSON/Firestore data
  factory OrganizationMembershipModel.fromJson(DataMap json) {
    return OrganizationMembershipModel(
      organizationId: json['organizationId'] as String? ?? '',
      organizationName: json['organizationName'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      role: json['role'] as String? ?? '',
      jobRole: json['jobRole'] as String?,
      department: json['department'] as String?,
      joinedAt: json['joinedAt'] != null
          ? (json['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts model to JSON/Firestore format
  DataMap toJson() {
    return {
      'organizationId': organizationId,
      'organizationName': organizationName,
      'userId': userId,
      'role': role,
      if (jobRole != null) 'jobRole': jobRole,
      if (department != null) 'department': department,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'isActive': isActive,
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (permissions != null) 'permissions': permissions,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Copy with method
  OrganizationMembershipModel copyWith({
    String? organizationId,
    String? organizationName,
    String? userId,
    String? role,
    String? jobRole,
    String? department,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? updatedAt,
    List<String>? permissions,
    Map<String, dynamic>? metadata,
  }) {
    return OrganizationMembershipModel(
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      jobRole: jobRole ?? this.jobRole,
      department: department ?? this.department,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      permissions: permissions ?? this.permissions,
      metadata: metadata ?? this.metadata,
    );
  }
}
