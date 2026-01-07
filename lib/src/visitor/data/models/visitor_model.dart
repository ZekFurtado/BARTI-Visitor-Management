import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/visitor.dart';

/// Visitor model that extends the visitor entity for data layer operations
class VisitorModel extends Visitor {
  const VisitorModel({
    super.id,
    required super.name,
    required super.origin,
    required super.purpose,
    required super.employeeToMeetId,
    required super.employeeToMeetName,
    super.photoUrl,
    required super.status,
    required super.gatekeeperId,
    required super.gatekeeperName,
    super.phoneNumber,
    super.email,
    required super.createdAt,
    super.updatedAt,
    super.notes,
    super.expectedDuration,
  });

  /// Creates an empty visitor model for testing
  VisitorModel.empty()
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

  /// Creates a visitor model from Firestore document
  factory VisitorModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VisitorModel(
      id: doc.id,
      name: data['name'] as String,
      origin: data['origin'] as String,
      purpose: data['purpose'] as String,
      employeeToMeetId: data['employeeToMeetId'] as String,
      employeeToMeetName: data['employeeToMeetName'] as String,
      photoUrl: data['photoUrl'] as String?,
      status: parseVisitorStatus(data['status'] as String?),
      gatekeeperId: data['gatekeeperId'] as String,
      gatekeeperName: data['gatekeeperName'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      email: data['email'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      notes: data['notes'] as String?,
      expectedDuration: data['expectedDuration'] as String?,
    );
  }

  /// Creates a visitor model from a Map (for API responses)
  factory VisitorModel.fromMap(Map<String, dynamic> map) {
    return VisitorModel(
      id: map['id'] as String?,
      name: map['name'] as String,
      origin: map['origin'] as String,
      purpose: map['purpose'] as String,
      employeeToMeetId: map['employeeToMeetId'] as String,
      employeeToMeetName: map['employeeToMeetName'] as String,
      photoUrl: map['photoUrl'] as String?,
      status: parseVisitorStatus(map['status'] as String?),
      gatekeeperId: map['gatekeeperId'] as String,
      gatekeeperName: map['gatekeeperName'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
      notes: map['notes'] as String?,
      expectedDuration: map['expectedDuration'] as String?,
    );
  }

  /// Converts the visitor model to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'origin': origin,
      'purpose': purpose,
      'employeeToMeetId': employeeToMeetId,
      'employeeToMeetName': employeeToMeetName,
      'photoUrl': photoUrl,
      'status': status.value,
      'gatekeeperId': gatekeeperId,
      'gatekeeperName': gatekeeperName,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'notes': notes,
      'expectedDuration': expectedDuration,
    };
  }

  /// Converts the visitor model to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'purpose': purpose,
      'employeeToMeetId': employeeToMeetId,
      'employeeToMeetName': employeeToMeetName,
      'photoUrl': photoUrl,
      'status': status.value,
      'gatekeeperId': gatekeeperId,
      'gatekeeperName': gatekeeperName,
      'phoneNumber': phoneNumber,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'expectedDuration': expectedDuration,
    };
  }

  /// Creates a copy of this visitor model with updated values
  VisitorModel copyWith({
    String? id,
    String? name,
    String? origin,
    String? purpose,
    String? employeeToMeetId,
    String? employeeToMeetName,
    String? photoUrl,
    VisitorStatus? status,
    String? gatekeeperId,
    String? gatekeeperName,
    String? phoneNumber,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    String? expectedDuration,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      origin: origin ?? this.origin,
      purpose: purpose ?? this.purpose,
      employeeToMeetId: employeeToMeetId ?? this.employeeToMeetId,
      employeeToMeetName: employeeToMeetName ?? this.employeeToMeetName,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      gatekeeperId: gatekeeperId ?? this.gatekeeperId,
      gatekeeperName: gatekeeperName ?? this.gatekeeperName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      expectedDuration: expectedDuration ?? this.expectedDuration,
    );
  }
}