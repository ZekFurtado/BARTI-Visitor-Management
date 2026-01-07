import 'package:equatable/equatable.dart';

/// Exceptions due to server errors
class ServerException extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const ServerException({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

class CacheException extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const CacheException({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

class LocalFileException extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const LocalFileException({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Network related exceptions
class NetworkException extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const NetworkException({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Exceptions due to Firebase or remote API authentication errors
class AuthException extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const AuthException({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Thrown if the password is invalid for the given email, or the account
/// corresponding to the email does not have a password set. depending on if you
/// are using firebase emulator or not the code is different
class InvalidCredentialsException extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const InvalidCredentialsException(
      {required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Thrown if the email address is not valid.
class InvalidEmail extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const InvalidEmail({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Thrown if there is no user corresponding to the given email.
class UserNotFound extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const UserNotFound({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Thrown if the user corresponding to the given email has been disabled.
class UserDisabled extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const UserDisabled({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

/// Thrown if the user sent too many requests at the same time, for security the
/// api will not allow too many attemps at the same time, user will have to wait
/// for some time
class FirebaseTooManyRequests extends Equatable implements Exception {
  final String statusCode;
  final String message;

  const FirebaseTooManyRequests(
      {required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

class SchemeException extends Equatable implements Exception {
  final String statusCode;

  final String message;

  const SchemeException({required this.statusCode, required this.message});

  @override
  List<Object?> get props => [statusCode, message];
}

class LocationException extends Equatable implements Exception {
  final String statusCode;

  final String message;

  const LocationException(this.statusCode, this.message);

  @override
  List<Object> get props => [statusCode, message];
}
