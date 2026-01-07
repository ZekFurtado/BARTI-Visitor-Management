import 'package:visitor_management/core/utils/typedef.dart';

import '../entities/user.dart';

/// Contains all the methods specific for the authentication process
abstract class AuthRepository {
  /// Automatically calls the respective class that implements this abstract
  /// class due to the dependency injection at runtime. For eg:
  ///         AuthCubit(
  ///           SignIn(
  ///               AuthRepositoryImpl(
  ///                   AuthRemoteDataSourceImpl()
  ///               )
  ///           )
  ///       )
  ///
  /// In this case, since the dependencies are already set by the [sl] service
  /// locator, the respective subclass' method will be called.
  ResultFuture<LocalUser> emailSignIn(
      {required String email, required String password});

  /// This method registers a new user on Firebase
  ResultFuture<LocalUser> createEmailUser(
      {required String email, required String password});

  /// This method registers a new user with role information
  ResultFuture<LocalUser> createUserWithRole({
    required String email,
    required String password,
    required String name,
    required String role,
    String? jobRole,
    String? department,
  });

  /// This method signs out the user from Firebase
  ResultVoid signOut();

  /// This method gets the user session if the user is logged in
  ResultFuture<LocalUser> getUserSession();
}
