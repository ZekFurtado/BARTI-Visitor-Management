part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

/// The initial state of the Authentication Phase
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

/// State to be exhibited when a new user is being registered
class CreatingUser extends AuthenticationState {
  const CreatingUser();
}

/// State to be exhibited when a user is signing in
class SigningInEmailUser extends AuthenticationState {
  const SigningInEmailUser();
}

class SigningOutUser extends AuthenticationState {
  const SigningOutUser();
}

class FetchingUserSession extends AuthenticationState {
  const FetchingUserSession();
}

/// State to be exhibited when a user has successfully been authenticated
class Authenticated extends AuthenticationState {
  const Authenticated(this.visitor);

  /// The user object returned from Firebase
  final LocalUser visitor;

  @override
  List<Object> get props => [visitor.uid ?? ''];
}

class SignedOut extends AuthenticationState {
  const SignedOut();
}

/// State to be exhibited when an error has occurred while authenticating the
/// user
class AuthenticationError extends AuthenticationState {
  const AuthenticationError({required this.message});

  /// Error message
  final String message;
}

class TogglePasswordVisibility extends AuthenticationState {
  final bool hidePass;

  const TogglePasswordVisibility({required this.hidePass});
}
