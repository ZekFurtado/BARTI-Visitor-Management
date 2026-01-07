part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object?> get props => [];
}

class CreateEmailUserEvent extends AuthenticationEvent {
  const CreateEmailUserEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email];
}

class CreateUserWithRoleEvent extends AuthenticationEvent {
  const CreateUserWithRoleEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.jobRole,
    this.department,
  });

  final String email;
  final String password;
  final String name;
  final String role;
  final String? jobRole;
  final String? department;

  @override
  List<Object?> get props => [email, password, name, role, jobRole, department];
}

class EmailSignInEvent extends AuthenticationEvent {
  const EmailSignInEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email];
}

class GetUserSessionEvent extends AuthenticationEvent {
  const GetUserSessionEvent();
}

class SignOutUserEvent extends AuthenticationEvent {
  const SignOutUserEvent();
}
