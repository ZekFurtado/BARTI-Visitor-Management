import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
           );

  /// Generates a [LocalUser] model from the [UserCredential] object received from
  /// Firebase.
  LocalUserModel.fromFirebase(User? user)
      : this(
            email: user?.email,
            uid: user?.uid,
            name: user?.displayName,
            profilePic: user?.photoURL,
           );

  /// Generates a [LocalUser] model from Firestore document data.
  LocalUserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
      : this(
            uid: doc.id,
            email: doc.data()?['email'] as String?,
            name: doc.data()?['name'] as String?,
            role: doc.data()?['role'] as String?,
            jobRole: doc.data()?['jobRole'] as String?,
            department: doc.data()?['department'] as String?,
            isFirstTime: doc.data()?['isFirstTime'] as bool? ?? true,
            phone: doc.data()?['phone'] as String?,
            profilePic: doc.data()?['profilePic'] as String?,
            createdOn: doc.data()?['createdOn'] as String?,
          );

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
    );
  }

  /// Converts the model to a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'jobRole': jobRole,
      'department': department,
      'isFirstTime': isFirstTime,
      'phone': phone,
      'profilePic': profilePic,
      'createdOn': createdOn,
    };
  }
}
