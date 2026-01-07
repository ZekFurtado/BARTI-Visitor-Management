import 'package:equatable/equatable.dart';

/// Employee entity representing an employee in the system
class Employee extends Equatable {
  /// Unique ID of the employee
  final String id;

  /// Full name of the employee
  final String name;

  /// Email address of the employee
  final String email;

  /// Job role/designation of the employee
  final String jobRole;

  /// Department the employee belongs to
  final String department;

  /// Phone number of the employee
  final String? phoneNumber;

  /// Profile picture URL
  final String? profilePictureUrl;

  /// Whether the employee is currently active
  final bool isActive;

  /// Office location or room number
  final String? officeLocation;

  /// Date when the employee joined
  final DateTime? joinedAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.jobRole,
    required this.department,
    this.phoneNumber,
    this.profilePictureUrl,
    this.isActive = true,
    this.officeLocation,
    this.joinedAt,
  });

  /// Creates an empty employee for testing purposes
  const Employee.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          email: 'empty.email',
          jobRole: 'empty.jobRole',
          department: 'empty.department',
        );

  /// Gets the employee's initials for avatar display
  String get initials {
    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '';
    if (nameParts.length == 1) return nameParts[0][0].toUpperCase();
    return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
  }

  /// Gets a formatted display name with job role
  String get displayNameWithRole => '$name • $jobRole';

  /// Gets a formatted department and role string
  String get departmentAndRole => '$jobRole • $department';

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        jobRole,
        department,
        phoneNumber,
        profilePictureUrl,
        isActive,
        officeLocation,
        joinedAt,
      ];
}