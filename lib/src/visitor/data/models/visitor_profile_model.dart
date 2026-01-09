import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_profile.dart';

/// Visitor profile model that extends the visitor profile entity for data layer operations
class VisitorProfileModel extends VisitorProfile {
  const VisitorProfileModel({
    super.id,
    required super.name,
    required super.phoneNumber,
    super.email,
    super.photoUrl,
    required super.createdAt,
    super.updatedAt,
    super.visits = const [],
    super.notes,
  });

  /// Creates an empty visitor profile model for testing
  VisitorProfileModel.empty() : super.empty();

  /// Creates a visitor profile model from Firestore document
  factory VisitorProfileModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Parse visits from subcollection or array
    final visitsData = data['visits'] as List<dynamic>? ?? [];
    final visits = visitsData
        .map((visitData) => VisitModel.fromMap(visitData as Map<String, dynamic>))
        .toList();

    return VisitorProfileModel(
      id: doc.id,
      name: data['name'] as String,
      phoneNumber: data['phoneNumber'] as String,
      email: data['email'] as String?,
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      visits: visits,
      notes: data['notes'] as String?,
    );
  }

  /// Creates a visitor profile model from a Map
  factory VisitorProfileModel.fromMap(Map<String, dynamic> map) {
    final visitsData = map['visits'] as List<dynamic>? ?? [];
    final visits = visitsData
        .map((visitData) => VisitModel.fromMap(visitData as Map<String, dynamic>))
        .toList();

    return VisitorProfileModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
      visits: visits,
      notes: map['notes'] as String?,
    );
  }

  /// Creates a visitor profile model from a visitor
  factory VisitorProfileModel.fromVisitor(Visitor visitor) {
    return VisitorProfileModel(
      name: visitor.name,
      phoneNumber: visitor.phoneNumber ?? '',
      email: visitor.email,
      photoUrl: visitor.photoUrl,
      createdAt: visitor.createdAt,
      visits: [VisitModel.fromVisitor(visitor)],
    );
  }

  /// Converts the visitor profile model to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'visits': visits.map((visit) => visit is VisitModel ? visit.toMap() : _visitToMap(visit)).toList(),
      'notes': notes,
    };
  }

  /// Converts the visitor profile model to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'visits': visits.map((visit) => visit is VisitModel ? visit.toMap() : _visitToMap(visit)).toList(),
      'notes': notes,
    };
  }

  /// Helper method to convert Visit entity to Map
  Map<String, dynamic> _visitToMap(Visit visit) {
    return {
      'id': visit.id,
      'origin': visit.origin,
      'purpose': visit.purpose,
      'employeeToMeetId': visit.employeeToMeetId,
      'employeeToMeetName': visit.employeeToMeetName,
      'status': visit.status.value,
      'gatekeeperId': visit.gatekeeperId,
      'gatekeeperName': visit.gatekeeperName,
      'visitDate': visit.visitDate.toIso8601String(),
      'updatedAt': visit.updatedAt?.toIso8601String(),
      'notes': visit.notes,
      'expectedDuration': visit.expectedDuration,
    };
  }

  /// Creates a copy of this visitor profile model with updated values
  @override
  VisitorProfileModel copyWith({
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
    return VisitorProfileModel(
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

  /// Adds a new visit to this visitor profile (specific for VisitModel)
  VisitorProfileModel addVisitModel(VisitModel visit) {
    final updatedVisits = <Visit>[...visits, visit];
    return copyWith(
      visits: updatedVisits,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a new visit to this visitor profile
  @override
  VisitorProfileModel addVisit(Visit visit) {
    final visitModel = visit is VisitModel ? visit : VisitModel(
      id: visit.id,
      origin: visit.origin,
      purpose: visit.purpose,
      employeeToMeetId: visit.employeeToMeetId,
      employeeToMeetName: visit.employeeToMeetName,
      status: visit.status,
      gatekeeperId: visit.gatekeeperId,
      gatekeeperName: visit.gatekeeperName,
      visitDate: visit.visitDate,
      updatedAt: visit.updatedAt,
      notes: visit.notes,
      expectedDuration: visit.expectedDuration,
    );
    final updatedVisits = <Visit>[...visits, visitModel];
    return copyWith(
      visits: updatedVisits,
      updatedAt: DateTime.now(),
    );
  }
}

/// Visit model that extends the visit entity for data layer operations
class VisitModel extends Visit {
  const VisitModel({
    super.id,
    required super.origin,
    required super.purpose,
    required super.employeeToMeetId,
    required super.employeeToMeetName,
    required super.status,
    required super.gatekeeperId,
    required super.gatekeeperName,
    required super.visitDate,
    super.updatedAt,
    super.notes,
    super.expectedDuration,
  });

  /// Creates a visit model from a visitor entity
  factory VisitModel.fromVisitor(Visitor visitor) {
    return VisitModel(
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

  /// Creates a visit model from a Map
  factory VisitModel.fromMap(Map<String, dynamic> map) {
    return VisitModel(
      id: map['id'] as String?,
      origin: map['origin'] as String,
      purpose: map['purpose'] as String,
      employeeToMeetId: map['employeeToMeetId'] as String,
      employeeToMeetName: map['employeeToMeetName'] as String,
      status: parseVisitorStatus(map['status'] as String?),
      gatekeeperId: map['gatekeeperId'] as String,
      gatekeeperName: map['gatekeeperName'] as String,
      visitDate: map['visitDate'] is Timestamp
          ? (map['visitDate'] as Timestamp).toDate()
          : DateTime.parse(map['visitDate'] as String),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(map['updatedAt'] as String))
          : null,
      notes: map['notes'] as String?,
      expectedDuration: map['expectedDuration'] as String?,
    );
  }

  /// Converts the visit model to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'origin': origin,
      'purpose': purpose,
      'employeeToMeetId': employeeToMeetId,
      'employeeToMeetName': employeeToMeetName,
      'status': status.value,
      'gatekeeperId': gatekeeperId,
      'gatekeeperName': gatekeeperName,
      'visitDate': visitDate.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'expectedDuration': expectedDuration,
    };
  }

  /// Creates a copy of this visit model with updated values
  @override
  VisitModel copyWith({
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
    return VisitModel(
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
}