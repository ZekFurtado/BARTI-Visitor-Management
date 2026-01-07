import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:visitor_management/core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// The execution is in the data layer and this method is responsible for
  /// making the API call to Firebase for signing the user in to the app.
  Future<LocalUserModel> emailSignIn({
    required String email,
    required String password,
  });

  /// The execution is in the data layer and this method is responsible for
  /// making the API call to Google and Firebase for signing in with Google.
  Future<LocalUserModel> signInWithGoogle();


  /// The execution is in the data layer and this method is responsible for
  /// making the API call to Firebase for registering the user to the app.
  Future<LocalUserModel> createEmailUser({
    required String email,
    required String password,
  });

  /// The execution is in the data layer and this method is responsible for
  /// making the API call to Firebase for setting the username of the the user.
  Future<void> setUsername({required String username});

  /// The execution is in the data layer and this method is responsible for
  /// making the API call to Firebase for signing the user out of the app.
  Future<void> signOut();

  /// This method is responsible for getting the firebase user session object
  /// if the user is already signed in
  Future<LocalUserModel> getUserSession();

  /// This method is responsible for sending a password reset email
  Future<void> forgotPassword({required String email});

  /// This method is responsible for updating user profile
  Future<LocalUserModel> updateUserProfile({
    required String uid,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
    String? profilePic,
  });

  /// This method is responsible for changing user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// This method is responsible for deleting user account and all data
  Future<void> deleteAccount({required String password});

  /// This method marks the user as no longer first-time (onboarding completed)
  Future<void> markOnboardingCompleted({required String uid});

  /// This method retrieves user data from Firestore
  Future<LocalUserModel> getUserDataFromFirestore({required String uid});

  /// This method stores user data to Firestore during registration
  Future<void> storeUserDataToFirestore({
    required String uid,
    required String email,
    required String name,
    required String role,
    String? jobRole,
    String? department,
  });
}

/// This class deals with the authentication related remote API sources
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;


  AuthRemoteDataSourceImpl(this.firebaseAuth, this.googleSignIn);

  /// This method is automatically called due to the dependency injection at
  /// runtime. It calls the Firebase API for signing in the user and then
  /// fetches additional user data from Firestore.
  @override
  Future<LocalUserModel> emailSignIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((userCredential) async {
            final firebaseUser = LocalUserModel.fromFirebase(userCredential.user);
            
            // Fetch additional user data from Firestore
            if (firebaseUser.uid != null) {
              try {
                final userDataFromFirestore = await getUserDataFromFirestore(uid: firebaseUser.uid!);
                // Merge Firebase auth data with Firestore user data
                return firebaseUser.copyWith(
                  role: userDataFromFirestore.role,
                  jobRole: userDataFromFirestore.jobRole,
                  department: userDataFromFirestore.department,
                  isFirstTime: userDataFromFirestore.isFirstTime,
                  phone: userDataFromFirestore.phone,
                  createdOn: userDataFromFirestore.createdOn,
                );
              } catch (e) {
                // If Firestore data doesn't exist, return Firebase user data only
                // This handles cases where user registered but Firestore data wasn't created
                return firebaseUser;
              }
            }
            
            return firebaseUser;
          });
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential" ||
          e.code == "INVALID_LOGIN_CREDENTIALS" ||
          e.code == "wrong-password" ||
          e.code == "user-not-found") {
        throw InvalidCredentialsException(
          statusCode: e.code,
          message:
              "The credentials you have provided are invalid. Please try again",
        );
      } else if (e.code == "too-many-requests") {
        throw FirebaseTooManyRequests(
          statusCode: e.code,
          message: "Too many attempts. Please wait for some time",
        );
      } else if (e.code == "user-disabled") {
        throw UserDisabled(
          statusCode: e.code,
          message: "This user has been disabled. Please contact support",
        );
      } else {
        throw AuthException(
          statusCode: e.code,
          message: e.message ?? "An authentication error occurred",
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } catch (e) {
      throw const AuthException(
        statusCode: "error",
        message: "An authentication error occurred",
      );
    }
  }

  /// This method handles Google Sign-In authentication
  @override
  Future<LocalUserModel> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException(
          statusCode: "cancelled",
          message: "Sign in was cancelled by the user",
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);

      // Create and return VisitorModel
      return LocalUserModel.fromFirebase(userCredential.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw AuthException(
          statusCode: e.code,
          message: "An account already exists with a different credential",
        );
      } else if (e.code == 'invalid-credential') {
        throw AuthException(
          statusCode: e.code,
          message: "The credential received is invalid",
        );
      } else {
        throw AuthException(
          statusCode: e.code,
          message: e.message ?? "Google Sign-In failed",
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } catch (e) {
      print(e);
      throw const AuthException(
        statusCode: "error",
        message: "An error occurred during Google Sign-In",
      );
    }
  }

  /// This method is automatically called due to the dependency injection at
  /// runtime. It calls the Firebase API for registering the user.
  @override
  Future<LocalUserModel> createEmailUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final localUser = LocalUserModel.fromFirebase(userCredential.user);

      return localUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "An error occurred while creating the user",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  /// This method is automatically called due to the dependency injection at
  /// runtime. It calls the Firebase API for setting the username of the user.
  @override
  Future<void> setUsername({required String username}) async {
    try {
      await firebaseAuth.currentUser?.updateDisplayName(username);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "An error occurred",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  /// This method is automatically called due to the dependency injection at
  /// runtime. It calls the Firebase API for signing out the user.
  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google if user is signed in with Google
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      // Sign out from Firebase
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "An error occurred",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<LocalUserModel> getUserSession() async {
    try {
      final user = firebaseAuth.currentUser;
      
      if (user == null) {
        throw const AuthException(
          statusCode: "401",
          message: "No user session found",
        );
      }

      final firebaseUser = LocalUserModel.fromFirebase(user);
      
      // Fetch additional user data from Firestore
      try {
        final userDataFromFirestore = await getUserDataFromFirestore(uid: firebaseUser.uid!);
        // Merge Firebase auth data with Firestore user data
        return firebaseUser.copyWith(
          role: userDataFromFirestore.role,
          jobRole: userDataFromFirestore.jobRole,
          department: userDataFromFirestore.department,
          isFirstTime: userDataFromFirestore.isFirstTime,
          phone: userDataFromFirestore.phone,
          createdOn: userDataFromFirestore.createdOn,
        );
      } catch (e) {
        // If Firestore data doesn't exist, return Firebase user data only
        return firebaseUser;
      }
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "An error occurred while creating the user",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException(
          statusCode: e.code,
          message: "No user found with this email address",
        );
      } else if (e.code == 'invalid-email') {
        throw AuthException(
          statusCode: e.code,
          message: "Please enter a valid email address",
        );
      } else {
        throw AuthException(
          statusCode: e.code,
          message: e.message ?? "Failed to send reset email",
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<LocalUserModel> updateUserProfile({
    required String uid,
    String? name,
    String? firstName,
    String? lastName,
    String? phone,
    String? profilePic,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          statusCode: "401",
          message: "User not authenticated",
        );
      }

      // Update display name if provided
      if (name != null) {
        await user.updateDisplayName(name);
      }

      // Update profile picture if provided
      if (profilePic != null) {
        await user.updatePhotoURL(profilePic);
      }

      // Update Firestore user document with firstName, lastName, and phone
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(uid);

      final updateData = <String, dynamic>{};

      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phone != null) updateData['phone'] = phone;
      if (name != null) updateData['fullName'] = name;

      if (updateData.isNotEmpty) {
        await userDocRef.set(updateData, SetOptions(merge: true));
      }

      // Reload user to get updated information
      await user.reload();
      final updatedUser = firebaseAuth.currentUser;

      return LocalUserModel.fromFirebase(updatedUser);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "Failed to update profile",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          statusCode: "401",
          message: "User not authenticated",
        );
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw AuthException(
          statusCode: e.code,
          message: "Current password is incorrect",
        );
      } else if (e.code == 'weak-password') {
        throw AuthException(
          statusCode: e.code,
          message: "New password is too weak",
        );
      } else {
        throw AuthException(
          statusCode: e.code,
          message: e.message ?? "Failed to change password",
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException(
          statusCode: "401",
          message: "User not authenticated",
        );
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore before deleting account
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(user.uid);
      await userDocRef.delete();

      // Delete the user account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw AuthException(
          statusCode: e.code,
          message: "Password is incorrect",
        );
      } else if (e.code == 'requires-recent-login') {
        throw AuthException(
          statusCode: e.code,
          message: "Please sign in again before deleting your account",
        );
      } else {
        throw AuthException(
          statusCode: e.code,
          message: e.message ?? "Failed to delete account",
        );
      }
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<void> markOnboardingCompleted({required String uid}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(uid).update({
        'isFirstTime': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "Failed to update onboarding status",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<LocalUserModel> getUserDataFromFirestore({required String uid}) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        throw AuthException(
          statusCode: "404",
          message: "User data not found in Firestore",
        );
      }
      
      return LocalUserModel.fromFirestore(userDoc);
    } on FirebaseException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "Failed to retrieve user data",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }

  @override
  Future<void> storeUserDataToFirestore({
    required String uid,
    required String email,
    required String name,
    required String role,
    String? jobRole,
    String? department,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userData = {
        'email': email,
        'name': name,
        'role': role,
        'jobRole': jobRole,
        'department': department,
        'isFirstTime': true,
        'createdOn': FieldValue.serverTimestamp().toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await firestore.collection('users').doc(uid).set(userData);
    } on FirebaseException catch (e) {
      throw AuthException(
        statusCode: e.code,
        message: e.message ?? "Failed to store user data",
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    } on http.ClientException {
      throw const NetworkException(
        statusCode: "404",
        message: "No Internet. Please check your network connection",
      );
    }
  }
}
