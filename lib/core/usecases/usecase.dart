import 'package:visitor_management/core/utils/typedef.dart';

/// Generic class for use cases to access their parameters by extending this
/// class instead of adding the required parameters as dependencies
abstract class UseCaseWithParams<Type, Params> {
  const UseCaseWithParams();

  ResultFuture<Type> call(Params params);
}

/// Generic class for use cases that do not require parameters
abstract class UseCaseWithoutParams<Type> {
  const UseCaseWithoutParams();

  ResultFuture<Type> call();
}

/// Generic class for stream use cases with parameters
abstract class StreamUsecase<Type, Params> {
  const StreamUsecase();

  Stream<Type> call(Params params);
}
