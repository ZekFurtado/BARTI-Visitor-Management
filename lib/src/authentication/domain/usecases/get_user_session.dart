import 'package:visitor_management/core/usecases/usecase.dart';
import 'package:visitor_management/core/utils/typedef.dart';
import 'package:visitor_management/src/authentication/domain/repositories/auth_repository.dart';

class GetUserSession extends UseCaseWithoutParams {
  final AuthRepository repository;

  GetUserSession(this.repository);

  @override
  ResultFuture call() {
    return repository.getUserSession();
  }
}
