import 'package:equatable/equatable.dart';
import 'package:visitor_management/core/errors/exceptions.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message, required this.statusCode});

  final String message;
  final String statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// API or Firebase errors
class ServerFailure extends Failure {
  const ServerFailure({required super.message, required super.statusCode});
}

/// No internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, required super.statusCode});
}

/// Authentication Errors
class AuthFailure extends Failure {
  const AuthFailure({required super.message, required super.statusCode});

  AuthFailure.fromException(AuthException exception)
      : this(statusCode: exception.statusCode, message: exception.message);
}

/// Cache Errors
class CacheFailure extends Failure {
  const CacheFailure({required super.message, required super.statusCode});
}

/// Local File Errors
class LocalFileFailure extends Failure {
  const LocalFileFailure({required super.message, required super.statusCode});
}

/// Scheme API Call related Failures
class SchemeFailure extends Failure {
  const SchemeFailure({required super.message, required super.statusCode});
}
