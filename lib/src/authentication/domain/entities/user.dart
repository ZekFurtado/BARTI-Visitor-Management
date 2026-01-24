import 'package:equatable/equatable.dart';
import 'package:visitor_management/src/organization/domain/entities/organization_membership.dart';

/// Represents the field resource that will use the app
class LocalUser extends Equatable {
  /// Unique ID of the user assigned by Firebase
  final String? uid;

  /// DEPRECATED: Use organizationMemberships instead
  /// Role of the user (Gatekeeper/Employee)
  /// This field is maintained for backward compatibility with single-tenant mode
  @Deprecated('Use getRoleInOrg() with organization context instead')
  final String? role;

  /// DEPRECATED: Use organizationMemberships instead
  /// Job role of the user (if Employee)
  /// This field is maintained for backward compatibility with single-tenant mode
  @Deprecated('Use getMembershipForOrg() with organization context instead')
  final String? jobRole;

  /// DEPRECATED: Use organizationMemberships instead
  /// Department of the user (if Employee)
  /// This field is maintained for backward compatibility with single-tenant mode
  @Deprecated('Use getMembershipForOrg() with organization context instead')
  final String? department;

  /// Whether this is the user's first time using the app
  final bool? isFirstTime;

  /// Username of the user if set
  final String? name;

  /// Email of the user
  final String? email;

  /// User phone
  final String? phone;

  /// URL of the profile picture of the user if set
  final String? profilePic;

  final String? createdOn;

  /// NEW: Multi-organization support
  /// List of organizations this user belongs to, with role in each
  final List<OrganizationMembership> organizationMemberships;

  const LocalUser({
    required this.uid,
    this.role,
    this.jobRole,
    this.department,
    this.isFirstTime,
    required this.name,
    required this.email,
    this.phone,
    this.profilePic,
    this.createdOn,
    this.organizationMemberships = const [],
  });

  /// Generates a default user primarily for tests
  const LocalUser.empty()
      : this(
          email: 'empty.email',
          role: 'empty.role',
          jobRole: 'empty.jobRole',
          department: 'empty.department',
          isFirstTime: true,
          name: 'empty.name',
          uid: 'empty.uid',
          organizationMemberships: const [],
        );

  /// Get the membership for a specific organization
  OrganizationMembership? getMembershipForOrg(String orgId) {
    try {
      return organizationMemberships.firstWhere(
        (m) => m.organizationId == orgId && m.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get the user's role in a specific organization
  String? getRoleInOrg(String orgId) {
    return getMembershipForOrg(orgId)?.role;
  }

  /// Get the user's job role in a specific organization
  String? getJobRoleInOrg(String orgId) {
    return getMembershipForOrg(orgId)?.jobRole;
  }

  /// Get the user's department in a specific organization
  String? getDepartmentInOrg(String orgId) {
    return getMembershipForOrg(orgId)?.department;
  }

  /// Check if the user has access to a specific organization
  bool hasAccessToOrg(String orgId) {
    return getMembershipForOrg(orgId) != null;
  }

  /// Check if the user is an admin in a specific organization
  bool isAdminInOrg(String orgId) {
    return getMembershipForOrg(orgId)?.isAdmin ?? false;
  }

  /// Check if the user is an owner of a specific organization
  bool isOwnerOfOrg(String orgId) {
    return getMembershipForOrg(orgId)?.isOwner ?? false;
  }

  /// Check if the user is a gatekeeper in a specific organization
  bool isGatekeeperInOrg(String orgId) {
    return getMembershipForOrg(orgId)?.isGatekeeper ?? false;
  }

  /// Check if the user is an employee in a specific organization
  bool isEmployeeInOrg(String orgId) {
    return getMembershipForOrg(orgId)?.isEmployee ?? false;
  }

  /// Get all organizations the user belongs to
  List<String> get organizationIds {
    return organizationMemberships
        .where((m) => m.isActive)
        .map((m) => m.organizationId)
        .toList();
  }

  /// Get count of active organizations
  int get organizationCount {
    return organizationMemberships.where((m) => m.isActive).length;
  }

  /// Check if user belongs to multiple organizations
  bool get belongsToMultipleOrgs {
    return organizationCount > 1;
  }

  @override
  List<Object?> get props => [
        uid,
        role,
        jobRole,
        department,
        isFirstTime,
        name,
        email,
        phone,
        profilePic,
        createdOn,
        organizationMemberships,
      ];
}
