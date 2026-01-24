import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:visitor_management/src/organization/data/models/organization_membership_model.dart';
import 'package:visitor_management/src/organization/domain/entities/organization_membership.dart';

import '../../domain/entities/user.dart';

/// The model of the visitor class. This model extends the entity and adds
/// additional features to it. This is the model that will be used throughout
/// the data layer.
class LocalUserModel extends LocalUser {
  const LocalUserModel({
    required super.uid,
    super.role,
    super.jobRole,
    super.department,
    super.isFirstTime,
    required super.name,
    required super.email,
    super.phone,
    super.profilePic,
    super.createdOn,
    super.organizationMemberships,
  });

  /// Generates a default User Model. This is also primary used for testing.
  const LocalUserModel.empty()
      : this(
          uid: 'empty.uid',
          role: 'empty.role',
          jobRole: 'empty.jobRole',
          department: 'empty.department',
          isFirstTime: true,
          name: 'empty.name',
          email: 'empty.email',
          organizationMemberships: const [],
        );

  /// Generates a [LocalUser] model from the [UserCredential] object received from
  /// Firebase.
  LocalUserModel.fromFirebase(User? user)
      : this(
          email: user?.email,
          uid: user?.uid,
          name: user?.displayName,
          profilePic: user?.photoURL,
          organizationMemberships: const [],
        );

  /// Generates a [LocalUser] model from Firestore document data.
  /// Supports both single-tenant (legacy) and multi-tenant modes.
  LocalUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
      : this(
          uid: doc.id,
          email: doc.data()?['email'] as String?,
          name: doc.data()?['name'] as String?,
          // Legacy fields (backward compatibility for single-tenant mode)
          role: doc.data()?['role'] as String?,
          jobRole: doc.data()?['jobRole'] as String?,
          department: doc.data()?['department'] as String?,
          isFirstTime: doc.data()?['isFirstTime'] as bool? ?? true,
          phone: doc.data()?['phone'] as String?,
          profilePic: doc.data()?['profilePic'] as String?,
          createdOn: doc.data()?['createdOn'] as String?,
          // Multi-tenant support
          organizationMemberships: _parseOrganizationMemberships(doc.data()),
        );

  /// Parse organization memberships from Firestore data
  /// Handles backward compatibility for users without organizationMemberships
  static List<OrganizationMembership> _parseOrganizationMemberships(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return const [];

    // Check if organizationMemberships field exists (multi-tenant mode)
    if (data.containsKey('organizationMemberships')) {
      final membershipsData = data['organizationMemberships'] as List?;
      if (membershipsData != null) {
        return membershipsData
            .map((membership) => OrganizationMembershipModel.fromJson(
                  membership as Map<String, dynamic>,
                ))
            .toList();
      }
    }

    // Backward compatibility: If no organizationMemberships but has role,
    // this is a legacy single-tenant user - return empty list
    // (Migration script will need to add memberships later)
    return const [];
  }

  /// Adds the new properties to the existing [LocalUser] object. This method is
  /// called after the user has signed in to Firebase and has retrieved its
  /// additional data from Firestore
  LocalUserModel copyWith({
    String? uid,
    String? role,
    String? jobRole,
    String? department,
    bool? isFirstTime,
    String? name,
    String? email,
    String? phone,
    String? profilePic,
    String? createdOn,
    List<OrganizationMembership>? organizationMemberships,
  }) {
    return LocalUserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      jobRole: jobRole ?? this.jobRole,
      department: department ?? this.department,
      isFirstTime: isFirstTime ?? this.isFirstTime,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      createdOn: createdOn ?? this.createdOn,
      organizationMemberships:
          organizationMemberships ?? this.organizationMemberships,
    );
  }

  /// Converts the model to a Map for Firestore storage
  /// Includes both legacy fields (for backward compatibility) and new fields
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      // Legacy fields (maintain for backward compatibility)
      'role': role,
      'jobRole': jobRole,
      'department': department,
      'isFirstTime': isFirstTime,
      'phone': phone,
      'profilePic': profilePic,
      'createdOn': createdOn,
      // Multi-tenant fields
      if (organizationMemberships.isNotEmpty)
        'organizationMemberships': organizationMemberships
            .map((membership) =>
                (membership as OrganizationMembershipModel).toJson())
            .toList(),
    };
  }

  /// Helper: Add an organization membership to the user
  LocalUserModel addOrganizationMembership(
    OrganizationMembership membership,
  ) {
    final updatedMemberships = [
      ...organizationMemberships,
      membership,
    ];
    return copyWith(organizationMemberships: updatedMemberships);
  }

  /// Helper: Remove an organization membership from the user
  LocalUserModel removeOrganizationMembership(String organizationId) {
    final updatedMemberships = organizationMemberships
        .where((m) => m.organizationId != organizationId)
        .toList();
    return copyWith(organizationMemberships: updatedMemberships);
  }

  /// Helper: Update an organization membership
  LocalUserModel updateOrganizationMembership(
    String organizationId,
    OrganizationMembership updatedMembership,
  ) {
    final updatedMemberships = organizationMemberships.map((m) {
      if (m.organizationId == organizationId) {
        return updatedMembership;
      }
      return m;
    }).toList();
    return copyWith(organizationMemberships: updatedMemberships);
  }
}
