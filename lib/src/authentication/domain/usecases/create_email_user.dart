import 'package:equatable/equatable.dart';
import 'package:visitor_management/core/usecases/usecase.dart';
import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/authentication/domain/repositories/auth_repository.dart';

import '../entities/user.dart';

/// This use case executes the business logic for registering a user. The
/// execution will move to the data layer by automatically calling the method
/// of the subclass of the dependency based on the dependency injection defined
/// in [lib/core/services/injection_container.dart]
class CreateUser extends UseCaseWithParams<LocalUser, CreateUserParams> {
  const CreateUser(this._repository);

  /// Depends on the [AuthRepository] for its operations
  final AuthRepository _repository;

  /// Calls the [_repository.createEmailUser] method from the repository.
  ResultFuture<LocalUser> createUser({
    required String email,
    required String password,
  }) async =>
      _repository.createEmailUser(
        email: email,
        password: password,
      );

  @override
  ResultFuture<LocalUser> call(CreateUserParams params) async =>
      _repository.createEmailUser(
        email: params.email,
        password: params.password,
      );
}

/// This is the parameters class designed for the [CreateUser] class which
/// contains the parameters required for the [CreateUser] functionality. This
/// is so that the [CreateUser] class only requires the [AuthRepository] as its
/// dependency and can still get the required parameters by extending this
/// class.
class CreateUserParams extends Equatable {
  const CreateUserParams({required this.email, required this.password});

  const CreateUserParams.empty()
      : this(email: 'empty.email', password: 'empty.password');

  final String email;
  final String password;

  @override
  List<Object?> get props => [email];
}
