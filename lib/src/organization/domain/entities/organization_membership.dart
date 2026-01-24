import 'package:equatable/equatable.dart';

/// Represents a user's membership in an organization
/// A user can belong to multiple organizations with different roles in each
class OrganizationMembership extends Equatable {
  /// ID of the organization
  final String organizationId;

  /// Name of the organization
  final String organizationName;

  /// ID of the user
  final String userId;

  /// User's role in this organization (Gatekeeper, Employee, Admin, Owner)
  final String role;

  /// User's job title/position in this organization
  final String? jobRole;

  /// User's department in this organization
  final String? department;

  /// When the user joined this organization
  final DateTime joinedAt;

  /// Whether this membership is currently active
  final bool isActive;

  /// When this membership was last updated
  final DateTime? updatedAt;

  /// Custom permissions for this user in the organization
  final List<String>? permissions;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const OrganizationMembership({
    required this.organizationId,
    required this.organizationName,
    required this.userId,
    required this.role,
    this.jobRole,
    this.department,
    required this.joinedAt,
    this.isActive = true,
    this.updatedAt,
    this.permissions,
    this.metadata,
  });

  /// Creates an empty organization membership
  OrganizationMembership.empty()
      : organizationId = '',
        organizationName = '',
        userId = '',
        role = '',
        jobRole = null,
        department = null,
        joinedAt = DateTime.now(),
        isActive = false,
        updatedAt = null,
        permissions = null,
        metadata = null;

  /// Check if user has a specific permission
  bool hasPermission(String permission) {
    if (permissions == null) return false;
    return permissions!.contains(permission);
  }

  /// Check if user is an admin in this organization
  bool get isAdmin => role.toLowerCase() == 'admin';

  /// Check if user is an owner of this organization
  bool get isOwner => role.toLowerCase() == 'owner';

  /// Check if user is a gatekeeper in this organization
  bool get isGatekeeper => role.toLowerCase() == 'gatekeeper';

  /// Check if user is an employee in this organization
  bool get isEmployee => role.toLowerCase() == 'employee';

  /// Check if user has elevated privileges (admin or owner)
  bool get hasElevatedPrivileges => isAdmin || isOwner;

  /// Get display name for role
  String get roleDisplayName {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'owner':
        return 'Owner';
      case 'gatekeeper':
        return 'Gatekeeper';
      case 'employee':
        return 'Employee';
      default:
        return role;
    }
  }

  /// Copy with method for creating modified memberships
  OrganizationMembership copyWith({
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
    return OrganizationMembership(
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

  /// Deactivate this membership
  OrganizationMembership deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Activate this membership
  OrganizationMembership activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Update role
  OrganizationMembership updateRole(String newRole) {
    return copyWith(
      role: newRole,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        organizationId,
        organizationName,
        userId,
        role,
        jobRole,
        department,
        joinedAt,
        isActive,
        updatedAt,
        permissions,
        metadata,
      ];

  @override
  String toString() {
    return 'OrganizationMembership(org: $organizationName, user: $userId, role: $role, active: $isActive)';
  }
}
