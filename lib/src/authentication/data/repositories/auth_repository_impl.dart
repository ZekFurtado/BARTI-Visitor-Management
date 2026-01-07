import 'package:dartz/dartz.dart';
import 'package:visitor_management/core/utils/typedef.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// This implementation is called based on the dependency injection.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  // Test-Driven Development
  // call the remote data source
  // check if the method returns the proper data
  // make sure that it returns the proper data if there is no exception
  // check if when the remoteDataSource throws an exception, we return a failure

  /// Calls the [emailSignIn] method from the remote data source. The execution
  /// is now in the data layer and will call the [remoteDataSource.emailSignIn]
  /// method. This method returns a [Right] or [Left] object based on success or
  /// failure.
  @override
  ResultFuture<LocalUser> emailSignIn(
      {required String email, required String password}) async {
    try {
      var visitorModel =
          await remoteDataSource.emailSignIn(email: email, password: password);
      // debugPrintvisitorModelWithAdditionalData);
      // return Right(visitorModel);
      return Right(visitorModel);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on InvalidCredentialsException {
      return const Left(
          ServerFailure(message: 'Invalid Credentials', statusCode: "001"));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return const Left(AuthFailure(message: "None", statusCode: "None"));
    }
  }

  /// Calls the [signOut] method from the remote data source. The execution is
  /// now in the data layer and will call the [remoteDataSource.signOut] method.
  /// This method returns a [Right] or [Left] object based on success or
  /// failure.
  @override
  ResultVoid signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on Exception {
      return const Left(ServerFailure(message: '', statusCode: "002"));
    }
  }

  /// Calls the [createEmailUser] method from the remote data source. The
  /// execution is now in the data layer and will call the
  /// [remoteDataSource.createEmailUser] method. This method returns a [Right]
  /// or [Left] object based on success or failure.
  @override
  ResultFuture<LocalUser> createEmailUser(
      {required String email, required String password}) async {
    try {
      final visitor = await remoteDataSource.createEmailUser(
          email: email, password: password);
      return Right(visitor);
    } on ServerException {
      return const Left(ServerFailure(message: '', statusCode: "003"));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<LocalUser> getUserSession() async {
    try {
      final visitorModel = await remoteDataSource.getUserSession();
      return Right(visitorModel);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException {
      return const Left(ServerFailure(message: '', statusCode: "001"));
    } on InvalidCredentialsException {
      return const Left(
          ServerFailure(message: 'Invalid Credentials', statusCode: "001"));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  ResultFuture<LocalUser> createUserWithRole({
    required String email,
    required String password,
    required String name,
    required String role,
    String? jobRole,
    String? department,
  }) async {
    try {
      // First create user in Firebase Auth
      final user = await remoteDataSource.createEmailUser(
        email: email,
        password: password,
      );

      // Set display name in Firebase Auth
      await remoteDataSource.setUsername(username: name);

      // Store additional user data in Firestore
      await remoteDataSource.storeUserDataToFirestore(
        uid: user.uid!,
        email: email,
        name: name,
        role: role,
        jobRole: jobRole,
        department: department,
      );

      // Return user with complete data
      return Right(user.copyWith(
        name: name,
        role: role,
        jobRole: jobRole,
        department: department,
        isFirstTime: true,
      ));
    } on ServerException {
      return const Left(ServerFailure(message: '', statusCode: "003"));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
