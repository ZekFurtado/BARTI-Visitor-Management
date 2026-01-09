import '../../../../core/utils/typedef.dart';
import '../entities/dashboard_stats.dart';

/// Abstract repository for dashboard operations
abstract class DashboardRepository {
  /// Get dashboard statistics for gatekeeper
  ResultFuture<DashboardStats> getGatekeeperStats();

  /// Get dashboard statistics for employee
  ResultFuture<DashboardStats> getEmployeeStats(String employeeId);

  /// Get today's visitor count
  ResultFuture<int> getTodayVisitorCount();

  /// Get pending approval count for an employee
  ResultFuture<int> getPendingApprovalsCount(String employeeId);

  /// Get total pending approvals (for gatekeeper view)
  ResultFuture<int> getTotalPendingApprovals();

  /// Get real-time dashboard statistics for gatekeeper
  Stream<DashboardStats> getGatekeeperStatsStream();

  /// Get real-time dashboard statistics for employee
  Stream<DashboardStats> getEmployeeStatsStream(String employeeId);
}