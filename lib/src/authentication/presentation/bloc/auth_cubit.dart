import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

/*class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit(
      {required CreateUser createUser, required EmailSignIn emailSignIn})
      : _emailSignIn = emailSignIn,
        super(const AuthenticationInitial());

  final EmailSignIn _emailSignIn;

  /// Calls the Sign In use case. The execution will move to the domain layer.
  Future<void> emailSignIn(
      {required String email, required String password}) async {
    emit(const SigningInEmailUser());

    final result =
        await _emailSignIn(EmailSignInParams(email: email, password: password));

    result.fold((failure) => emit(AuthenticationError(failure.statusCode)),
        (visitor) => emit(Authenticated(visitor)));
  }
}*/

class PasswordVisibilityCubit extends Cubit<bool> {
  PasswordVisibilityCubit() : super(true);

  void toggle() => emit(!state);
}
