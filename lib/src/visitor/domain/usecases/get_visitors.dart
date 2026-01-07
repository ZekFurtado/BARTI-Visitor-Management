import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

/// Use case for getting all visitors
class GetVisitors extends UseCaseWithoutParams<List<Visitor>> {
  final VisitorRepository repository;

  GetVisitors(this.repository);

  @override
  ResultFuture<List<Visitor>> call() {
    return repository.getAllVisitors();
  }
}

/// Use case for getting visitors for a specific employee
class GetVisitorsForEmployee extends UseCaseWithParams<List<Visitor>, GetVisitorsForEmployeeParams> {
  final VisitorRepository repository;

  GetVisitorsForEmployee(this.repository);

  @override
  ResultFuture<List<Visitor>> call(GetVisitorsForEmployeeParams params) {
    return repository.getVisitorsForEmployee(params.employeeId);
  }
}

/// Parameters for getting visitors for employee
class GetVisitorsForEmployeeParams extends Equatable {
  final String employeeId;

  const GetVisitorsForEmployeeParams({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

/// Use case for getting visitors by status
class GetVisitorsByStatus extends UseCaseWithParams<List<Visitor>, GetVisitorsByStatusParams> {
  final VisitorRepository repository;

  GetVisitorsByStatus(this.repository);

  @override
  ResultFuture<List<Visitor>> call(GetVisitorsByStatusParams params) {
    return repository.getVisitorsByStatus(params.status);
  }
}

/// Parameters for getting visitors by status
class GetVisitorsByStatusParams extends Equatable {
  final VisitorStatus status;

  const GetVisitorsByStatusParams({required this.status});

  @override
  List<Object> get props => [status];
}