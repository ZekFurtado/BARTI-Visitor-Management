import 'package:equatable/equatable.dart';
import 'package:visitor_management/core/usecases/usecase.dart';
import 'package:visitor_management/core/utils/typedef.dart';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// This use case executes the business logic for signing in a user. The
/// execution will move to the data layer by automatically calling the method
/// of the subclass of the dependency based on the dependency injection defined
/// in [lib/core/services/injection_container.dart]
class EmailSignIn extends UseCaseWithParams<LocalUser, EmailSignInParams> {
  /// Depends on the [AuthRepository] for its operations
  final AuthRepository repository;

  EmailSignIn(this.repository);

  /// The [call] method allows the class' method to be called as a method
  /// directly using the class' object.
  ///
  /// For e.g.:
  ///
  /// final SignIn signInUseCase;
  ///
  /// signInUseCase(email, password)
  ///
  /// This method calls the repository's [signIn] method.
  @override
  ResultFuture<LocalUser> call(EmailSignInParams params) {
    return repository.emailSignIn(
        email: params.email, password: params.password);
  }
}

/// This is the parameters class designed for the [EmailSignIn] class which
/// contains the parameters required for the [EmailSignIn] functionality. This
/// is so that the [EmailSignIn] class only requires the [AuthRepository] as its
/// dependency and can still get the required parameters by extending this
/// class.
class EmailSignInParams extends Equatable {
  const EmailSignInParams({required this.email, required this.password});

  /// A test set of parameters
  const EmailSignInParams.empty()
      : this(email: 'empty.email', password: 'empty.password');

  final String email;
  final String password;

  @override
  List<Object?> get props => [email];
}
