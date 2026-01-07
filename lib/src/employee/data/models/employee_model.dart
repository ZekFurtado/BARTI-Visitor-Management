import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/employee.dart';

/// Employee model that extends the employee entity for data layer operations
class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.jobRole,
    required super.department,
    super.phoneNumber,
    super.profilePictureUrl,
    super.isActive = true,
    super.officeLocation,
    super.joinedAt,
  });

  /// Creates an empty employee model for testing
  const EmployeeModel.empty()
      : this(
          id: 'empty.id',
          name: 'empty.name',
          email: 'empty.email',
          jobRole: 'empty.jobRole',
          department: 'empty.department',
        );

  /// Creates an employee model from Firestore document
  factory EmployeeModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return EmployeeModel(
      id: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      jobRole: data['jobRole'] as String,
      department: data['department'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      profilePictureUrl: data['profilePictureUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      officeLocation: data['officeLocation'] as String?,
      joinedAt: data['joinedAt'] != null 
          ? (data['joinedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  /// Creates an employee model from a Map (for API responses)
  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      jobRole: map['jobRole'] as String,
      department: map['department'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      profilePictureUrl: map['profilePictureUrl'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      officeLocation: map['officeLocation'] as String?,
      joinedAt: map['joinedAt'] != null 
          ? DateTime.parse(map['joinedAt'] as String) 
          : null,
    );
  }

  /// Converts the employee model to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'jobRole': jobRole,
      'department': department,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'isActive': isActive,
      'officeLocation': officeLocation,
      'joinedAt': joinedAt != null ? Timestamp.fromDate(joinedAt!) : null,
    };
  }

  /// Converts the employee model to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'jobRole': jobRole,
      'department': department,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'isActive': isActive,
      'officeLocation': officeLocation,
      'joinedAt': joinedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this employee model with updated values
  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? jobRole,
    String? department,
    String? phoneNumber,
    String? profilePictureUrl,
    bool? isActive,
    String? officeLocation,
    DateTime? joinedAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      jobRole: jobRole ?? this.jobRole,
      department: department ?? this.department,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isActive: isActive ?? this.isActive,
      officeLocation: officeLocation ?? this.officeLocation,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}