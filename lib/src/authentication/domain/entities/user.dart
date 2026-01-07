import 'package:equatable/equatable.dart';

/// Represents the field resource that will use the app
class LocalUser extends Equatable {
  /// Unique ID of the user assigned by Firebase
  final String? uid;

  /// Role of the user (Gatekeeper/Employee)
  final String? role;

  /// Job role of the user (if Employee)
  final String? jobRole;

  /// Department of the user (if Employee)
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
      );

  @override
  List<Object?> get props => [uid, role, jobRole, department, isFirstTime, name, email, phone, profilePic, createdOn];
}
