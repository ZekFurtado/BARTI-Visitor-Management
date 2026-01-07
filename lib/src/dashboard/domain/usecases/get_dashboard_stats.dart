import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for getting gatekeeper dashboard statistics
class GetGatekeeperStats extends UseCaseWithoutParams<DashboardStats> {
  final DashboardRepository repository;

  GetGatekeeperStats(this.repository);

  @override
  ResultFuture<DashboardStats> call() {
    return repository.getGatekeeperStats();
  }
}

/// Use case for getting employee dashboard statistics
class GetEmployeeStats extends UseCaseWithParams<DashboardStats, GetEmployeeStatsParams> {
  final DashboardRepository repository;

  GetEmployeeStats(this.repository);

  @override
  ResultFuture<DashboardStats> call(GetEmployeeStatsParams params) {
    return repository.getEmployeeStats(params.employeeId);
  }
}

/// Parameters for getting employee stats
class GetEmployeeStatsParams extends Equatable {
  final String employeeId;

  const GetEmployeeStatsParams({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

/// Use case for getting today's visitor count
class GetTodayVisitorCount extends UseCaseWithoutParams<int> {
  final DashboardRepository repository;

  GetTodayVisitorCount(this.repository);

  @override
  ResultFuture<int> call() {
    return repository.getTodayVisitorCount();
  }
}

/// Use case for getting pending approvals count for an employee
class GetPendingApprovalsCount extends UseCaseWithParams<int, GetPendingApprovalsCountParams> {
  final DashboardRepository repository;

  GetPendingApprovalsCount(this.repository);

  @override
  ResultFuture<int> call(GetPendingApprovalsCountParams params) {
    return repository.getPendingApprovalsCount(params.employeeId);
  }
}

/// Parameters for getting pending approvals count
class GetPendingApprovalsCountParams extends Equatable {
  final String employeeId;

  const GetPendingApprovalsCountParams({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

/// Use case for getting total pending approvals
class GetTotalPendingApprovals extends UseCaseWithoutParams<int> {
  final DashboardRepository repository;

  GetTotalPendingApprovals(this.repository);

  @override
  ResultFuture<int> call() {
    return repository.getTotalPendingApprovals();
  }
}