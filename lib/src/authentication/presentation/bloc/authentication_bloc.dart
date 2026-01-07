import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/authentication/domain/usecases/create_email_user.dart';
import 'package:visitor_management/src/authentication/domain/usecases/create_user_with_role.dart';
import 'package:visitor_management/src/authentication/domain/usecases/email_sign_in.dart';
import 'package:visitor_management/src/authentication/domain/usecases/sign_out.dart';

import '../../domain/usecases/get_user_session.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required CreateUser createUser,
    required CreateUserWithRole createUserWithRole,
    required EmailSignIn emailSignIn,
    required GetUserSession getUserSession,
    required SignOutUseCase signOutUser,
  }) : _createUser = createUser,
        _createUserWithRole = createUserWithRole,
        _emailSignIn = emailSignIn,
        _getUserSession = getUserSession,
        _signOutUseCase = signOutUser,
        super(const AuthenticationInitial()) {
    on<CreateEmailUserEvent>(_createEmailUserHandler);
    on<CreateUserWithRoleEvent>(_createUserWithRoleHandler);
    on<EmailSignInEvent>(_emailSignInHandler);
    on<GetUserSessionEvent>(_getUserSessionHandler);
    on<SignOutUserEvent>(_signOutUserEventHandler);
  }

  final CreateUser _createUser;
  final CreateUserWithRole _createUserWithRole;
  final EmailSignIn _emailSignIn;
  final GetUserSession _getUserSession;
  final SignOutUseCase _signOutUseCase;

  Future<void> _createEmailUserHandler(
      CreateEmailUserEvent event, Emitter<AuthenticationState> emit) async {
    emit(const CreatingUser());

    final result = await _createUser(
        CreateUserParams(email: event.email, password: event.password));

    result.fold(
        (failure) => emit(AuthenticationError(message: failure.statusCode)),
        (visitor) => emit(Authenticated(visitor)));
  }

  Future<void> _createUserWithRoleHandler(
      CreateUserWithRoleEvent event, Emitter<AuthenticationState> emit) async {
    emit(const CreatingUser());

    final result = await _createUserWithRole(
      CreateUserWithRoleParams(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
        jobRole: event.jobRole,
        department: event.department,
      ),
    );

    result.fold(
        (failure) => emit(AuthenticationError(message: failure.message)),
        (user) => emit(Authenticated(user)));
  }

  Future<void> _emailSignInHandler(
      EmailSignInEvent event, Emitter<AuthenticationState> emit) async {
    emit(const SigningInEmailUser());

    final result = await _emailSignIn(
        EmailSignInParams(email: event.email, password: event.password));

    result.fold(
        (failure) => emit(AuthenticationError(message: failure.message)),
        (visitor) => emit(Authenticated(visitor)));
  }

  Future<void> _getUserSessionHandler(
      GetUserSessionEvent event, Emitter<AuthenticationState> emit) async {
    emit(const FetchingUserSession());

    final result = await _getUserSession();

    result.fold(
        (failure) => emit(AuthenticationError(message: failure.message)),
        (visitor) => emit(Authenticated(visitor)));
  }

  Future<void> _signOutUserEventHandler(
      SignOutUserEvent event, Emitter<AuthenticationState> emit) async {
    emit(const SigningOutUser());

    final result = await _signOutUseCase();

    result.fold(
        (failure) => emit(AuthenticationError(message: failure.message)),
        (visitor) => emit(const SignedOut()));
  }
}
