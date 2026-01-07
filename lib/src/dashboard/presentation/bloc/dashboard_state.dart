part of 'dashboard_bloc.dart';

/// Base state class for dashboard states
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state for dashboard
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state for dashboard
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// State when dashboard statistics are successfully loaded
class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final String userRole; // 'gatekeeper' or 'employee'
  final String? employeeId; // Only for employee role

  const DashboardLoaded({
    required this.stats,
    required this.userRole,
    this.employeeId,
  });

  @override
  List<Object?> get props => [stats, userRole, employeeId];

  /// Returns true if this is for a gatekeeper
  bool get isGatekeeper => userRole == 'gatekeeper';

  /// Returns true if this is for an employee
  bool get isEmployee => userRole == 'employee';
}

/// Error state for dashboard
class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}