import 'package:equatable/equatable.dart';

/// Visitor entity representing a visitor in the system
class Visitor extends Equatable {
  /// Unique ID of the visitor
  final String? id;

  /// Name of the visitor
  final String name;

  /// Origin/Company where the visitor is coming from
  final String origin;

  /// Purpose of the visit
  final String purpose;

  /// ID of the employee the visitor wants to meet
  final String employeeToMeetId;

  /// Name of the employee the visitor wants to meet
  final String employeeToMeetName;

  /// URL of the visitor's photo
  final String? photoUrl;

  /// Status of the visitor request
  final VisitorStatus status;

  /// ID of the gatekeeper who registered the visitor
  final String gatekeeperId;

  /// Name of the gatekeeper who registered the visitor
  final String gatekeeperName;

  /// Phone number of the visitor
  final String? phoneNumber;

  /// Email of the visitor (optional)
  final String? email;

  /// Date and time when the visitor was registered
  final DateTime createdAt;

  /// Date and time when the status was last updated
  final DateTime? updatedAt;

  /// Additional notes from gatekeeper
  final String? notes;

  /// Expected duration of the visit
  final String? expectedDuration;

  const Visitor({
    this.id,
    required this.name,
    required this.origin,
    required this.purpose,
    required this.employeeToMeetId,
    required this.employeeToMeetName,
    this.photoUrl,
    required this.status,
    required this.gatekeeperId,
    required this.gatekeeperName,
    this.phoneNumber,
    this.email,
    required this.createdAt,
    this.updatedAt,
    this.notes,
    this.expectedDuration,
  });

  /// Creates an empty visitor for testing
  Visitor.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          origin: 'empty.origin',
          purpose: 'empty.purpose',
          employeeToMeetId: 'empty.employee.id',
          employeeToMeetName: 'empty.employee.name',
          status: VisitorStatus.pending,
          gatekeeperId: 'empty.gatekeeper.id',
          gatekeeperName: 'empty.gatekeeper.name',
          createdAt: DateTime.now(),
        );

  @override
  List<Object?> get props => [
        id,
        name,
        origin,
        purpose,
        employeeToMeetId,
        employeeToMeetName,
        photoUrl,
        status,
        gatekeeperId,
        gatekeeperName,
        phoneNumber,
        email,
        createdAt,
        updatedAt,
        notes,
        expectedDuration,
      ];
}

/// Enum representing the status of a visitor request
enum VisitorStatus {
  pending,
  approved,
  rejected,
  completed,
}

/// Extension to get string representation of visitor status
extension VisitorStatusExtension on VisitorStatus {
  String get displayName {
    switch (this) {
      case VisitorStatus.pending:
        return 'Pending';
      case VisitorStatus.approved:
        return 'Approved';
      case VisitorStatus.rejected:
        return 'Rejected';
      case VisitorStatus.completed:
        return 'Completed';
    }
  }

  String get value {
    switch (this) {
      case VisitorStatus.pending:
        return 'pending';
      case VisitorStatus.approved:
        return 'approved';
      case VisitorStatus.rejected:
        return 'rejected';
      case VisitorStatus.completed:
        return 'completed';
    }
  }
}

/// Helper function to parse status from string
VisitorStatus parseVisitorStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return VisitorStatus.pending;
    case 'approved':
      return VisitorStatus.approved;
    case 'rejected':
      return VisitorStatus.rejected;
    case 'completed':
      return VisitorStatus.completed;
    default:
      return VisitorStatus.pending;
  }
}