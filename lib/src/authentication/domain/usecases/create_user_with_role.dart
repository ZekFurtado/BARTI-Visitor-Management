import 'package:equatable/equatable.dart';
import 'package:visitor_management/core/usecases/usecase.dart';
import 'package:visitor_management/core/utils/typedef.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// This use case executes the business logic for creating a user with role information.
class CreateUserWithRole extends UseCaseWithParams<LocalUser, CreateUserWithRoleParams> {
  /// Depends on the [AuthRepository] for its operations
  final AuthRepository repository;

  CreateUserWithRole(this.repository);

  /// The [call] method allows the class' method to be called as a method
  /// directly using the class' object.
  @override
  ResultFuture<LocalUser> call(CreateUserWithRoleParams params) {
    return repository.createUserWithRole(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
      jobRole: params.jobRole,
      department: params.department,
    );
  }
}

/// This is the parameters class designed for the [CreateUserWithRole] class.
class CreateUserWithRoleParams extends Equatable {
  const CreateUserWithRoleParams({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.jobRole,
    this.department,
  });

  /// A test set of parameters
  const CreateUserWithRoleParams.empty()
      : this(
          email: 'empty.email',
          password: 'empty.password',
          name: 'empty.name',
          role: 'empty.role',
        );

  final String email;
  final String password;
  final String name;
  final String role;
  final String? jobRole;
  final String? department;

  @override
  List<Object?> get props => [email, password, name, role, jobRole, department];
}