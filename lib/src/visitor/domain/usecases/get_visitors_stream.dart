import '../../../../core/usecases/usecase.dart';
import '../entities/visitor.dart';
import '../repositories/visitor_repository.dart';

/// Use case for getting real-time stream of visitors for a specific employee
class GetVisitorsForEmployeeStream extends StreamUsecase<List<Visitor>, GetVisitorsForEmployeeStreamParams> {
  final VisitorRepository repository;

  GetVisitorsForEmployeeStream(this.repository);

  @override
  Stream<List<Visitor>> call(GetVisitorsForEmployeeStreamParams params) {
    return repository.getVisitorsForEmployeeStream(params.employeeId);
  }
}

/// Parameters for GetVisitorsForEmployeeStream use case
class GetVisitorsForEmployeeStreamParams {
  final String employeeId;

  GetVisitorsForEmployeeStreamParams({required this.employeeId});
}

/// Use case for getting real-time stream of visitors by status
class GetVisitorsByStatusStream extends StreamUsecase<List<Visitor>, GetVisitorsByStatusStreamParams> {
  final VisitorRepository repository;

  GetVisitorsByStatusStream(this.repository);

  @override
  Stream<List<Visitor>> call(GetVisitorsByStatusStreamParams params) {
    return repository.getVisitorsByStatusStream(params.status);
  }
}

/// Parameters for GetVisitorsByStatusStream use case
class GetVisitorsByStatusStreamParams {
  final VisitorStatus status;

  GetVisitorsByStatusStreamParams({required this.status});
}