import 'package:equatable/equatable.dart';
import 'visitor.dart';

/// Visitor profile entity representing a visitor with visit history
class VisitorProfile extends Equatable {
  /// Unique ID of the visitor profile
  final String? id;

  /// Name of the visitor
  final String name;

  /// Phone number of the visitor (unique identifier)
  final String phoneNumber;

  /// Email of the visitor (optional)
  final String? email;

  /// URL of the visitor's photo (latest photo)
  final String? photoUrl;

  /// Date and time when the profile was created
  final DateTime createdAt;

  /// Date and time when the profile was last updated
  final DateTime? updatedAt;

  /// List of all visits by this visitor
  final List<Visit> visits;

  /// Additional notes about the visitor
  final String? notes;

  const VisitorProfile({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    this.visits = const [],
    this.notes,
  });

  /// Creates an empty visitor profile for testing
  VisitorProfile.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          phoneNumber: 'empty.phone',
          createdAt: DateTime.now(),
          visits: const [],
        );

  /// Creates a visitor profile with a single visit
  factory VisitorProfile.fromVisitor(Visitor visitor) {
    return VisitorProfile(
      name: visitor.name,
      phoneNumber: visitor.phoneNumber ?? '',
      email: visitor.email,
      photoUrl: visitor.photoUrl,
      createdAt: visitor.createdAt,
      visits: [Visit.fromVisitor(visitor)],
    );
  }

  /// Creates a copy of this visitor profile with updated values
  VisitorProfile copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Visit>? visits,
    String? notes,
  }) {
    return VisitorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      visits: visits ?? this.visits,
      notes: notes ?? this.notes,
    );
  }

  /// Adds a new visit to this visitor profile
  VisitorProfile addVisit(Visit visit) {
    final updatedVisits = [...visits, visit];
    return copyWith(
      visits: updatedVisits,
      updatedAt: DateTime.now(),
    );
  }

  /// Gets the latest visit
  Visit? get latestVisit {
    if (visits.isEmpty) return null;
    return visits.reduce((a, b) => a.visitDate.isAfter(b.visitDate) ? a : b);
  }

  /// Gets visit count
  int get visitCount => visits.length;

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        email,
        photoUrl,
        createdAt,
        updatedAt,
        visits,
        notes,
      ];
}

/// Visit entity representing a single visit by a visitor
class Visit extends Equatable {
  /// Unique ID of the visit
  final String? id;

  /// Origin/Company where the visitor is coming from
  final String origin;

  /// Purpose of the visit
  final String purpose;

  /// ID of the employee the visitor wants to meet
  final String employeeToMeetId;

  /// Name of the employee the visitor wants to meet
  final String employeeToMeetName;

  /// Status of the visitor request
  final VisitorStatus status;

  /// ID of the gatekeeper who registered the visit
  final String gatekeeperId;

  /// Name of the gatekeeper who registered the visit
  final String gatekeeperName;

  /// Date and time of the visit
  final DateTime visitDate;

  /// Date and time when the status was last updated
  final DateTime? updatedAt;

  /// Additional notes from gatekeeper
  final String? notes;

  /// Expected duration of the visit
  final String? expectedDuration;

  const Visit({
    this.id,
    required this.origin,
    required this.purpose,
    required this.employeeToMeetId,
    required this.employeeToMeetName,
    required this.status,
    required this.gatekeeperId,
    required this.gatekeeperName,
    required this.visitDate,
    this.updatedAt,
    this.notes,
    this.expectedDuration,
  });

  /// Creates a visit from a visitor entity
  factory Visit.fromVisitor(Visitor visitor) {
    return Visit(
      id: visitor.id,
      origin: visitor.origin,
      purpose: visitor.purpose,
      employeeToMeetId: visitor.employeeToMeetId,
      employeeToMeetName: visitor.employeeToMeetName,
      status: visitor.status,
      gatekeeperId: visitor.gatekeeperId,
      gatekeeperName: visitor.gatekeeperName,
      visitDate: visitor.createdAt,
      updatedAt: visitor.updatedAt,
      notes: visitor.notes,
      expectedDuration: visitor.expectedDuration,
    );
  }

  /// Creates an empty visit for testing
  Visit.empty()
      : this(
          id: 'empty.id',
          origin: 'empty.origin',
          purpose: 'empty.purpose',
          employeeToMeetId: 'empty.employee.id',
          employeeToMeetName: 'empty.employee.name',
          status: VisitorStatus.pending,
          gatekeeperId: 'empty.gatekeeper.id',
          gatekeeperName: 'empty.gatekeeper.name',
          visitDate: DateTime.now(),
        );

  /// Creates a copy of this visit with updated values
  Visit copyWith({
    String? id,
    String? origin,
    String? purpose,
    String? employeeToMeetId,
    String? employeeToMeetName,
    VisitorStatus? status,
    String? gatekeeperId,
    String? gatekeeperName,
    DateTime? visitDate,
    DateTime? updatedAt,
    String? notes,
    String? expectedDuration,
  }) {
    return Visit(
      id: id ?? this.id,
      origin: origin ?? this.origin,
      purpose: purpose ?? this.purpose,
      employeeToMeetId: employeeToMeetId ?? this.employeeToMeetId,
      employeeToMeetName: employeeToMeetName ?? this.employeeToMeetName,
      status: status ?? this.status,
      gatekeeperId: gatekeeperId ?? this.gatekeeperId,
      gatekeeperName: gatekeeperName ?? this.gatekeeperName,
      visitDate: visitDate ?? this.visitDate,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      expectedDuration: expectedDuration ?? this.expectedDuration,
    );
  }

  @override
  List<Object?> get props => [
        id,
        origin,
        purpose,
        employeeToMeetId,
        employeeToMeetName,
        status,
        gatekeeperId,
        gatekeeperName,
        visitDate,
        updatedAt,
        notes,
        expectedDuration,
      ];
}