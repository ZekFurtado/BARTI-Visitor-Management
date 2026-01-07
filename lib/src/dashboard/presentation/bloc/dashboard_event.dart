part of 'dashboard_bloc.dart';

/// Base event class for dashboard events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to get gatekeeper dashboard statistics
class GetGatekeeperStatsEvent extends DashboardEvent {
  const GetGatekeeperStatsEvent();
}

/// Event to get employee dashboard statistics
class GetEmployeeStatsEvent extends DashboardEvent {
  final String employeeId;

  const GetEmployeeStatsEvent({required this.employeeId});

  @override
  List<Object> get props => [employeeId];
}

/// Event to refresh dashboard statistics
class RefreshStatsEvent extends DashboardEvent {
  const RefreshStatsEvent();
}