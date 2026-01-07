import 'package:visitor_management/core/usecases/usecase.dart';
import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/authentication/domain/repositories/auth_repository.dart';

/// This use case executes the business logic for signing out a user. The
/// execution will move to the data layer by automatically calling the method
/// of the subclass of the dependency based on the dependency injection defined
/// in [lib/core/services/injection_container.dart]
class SignOutUseCase extends UseCaseWithoutParams {
  /// Depends on the [AuthRepository] for its operations
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  @override
  ResultVoid call() {
    return repository.signOut();
  }
}
