import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

/// Use case for registering a new visitor
class RegisterVisitor extends UseCaseWithParams<Visitor, RegisterVisitorParams> {
  final VisitorRepository repository;

  RegisterVisitor(this.repository);

  @override
  ResultFuture<Visitor> call(RegisterVisitorParams params) {
    return repository.registerVisitor(params.visitor);
  }
}

/// Parameters for registering a visitor
class RegisterVisitorParams extends Equatable {
  final Visitor visitor;

  const RegisterVisitorParams({required this.visitor});

  @override
  List<Object> get props => [visitor];
}