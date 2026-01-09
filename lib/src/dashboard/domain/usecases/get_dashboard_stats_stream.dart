import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for getting real-time stream of gatekeeper dashboard statistics
class GetGatekeeperStatsStream extends StreamUsecase<DashboardStats, NoParams> {
  final DashboardRepository repository;

  GetGatekeeperStatsStream(this.repository);

  @override
  Stream<DashboardStats> call(NoParams params) {
    return repository.getGatekeeperStatsStream();
  }
}

/// Use case for getting real-time stream of employee dashboard statistics
class GetEmployeeStatsStream extends StreamUsecase<DashboardStats, GetEmployeeStatsStreamParams> {
  final DashboardRepository repository;

  GetEmployeeStatsStream(this.repository);

  @override
  Stream<DashboardStats> call(GetEmployeeStatsStreamParams params) {
    return repository.getEmployeeStatsStream(params.employeeId);
  }
}

/// Parameters for GetEmployeeStatsStream use case
class GetEmployeeStatsStreamParams {
  final String employeeId;

  GetEmployeeStatsStreamParams({required this.employeeId});
}

/// No parameters class for use cases that don't need parameters
class NoParams {}