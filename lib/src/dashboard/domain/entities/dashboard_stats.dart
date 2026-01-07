import 'package:equatable/equatable.dart';

/// Dashboard statistics entity
class DashboardStats extends Equatable {
  final int todayVisitors;
  final int pendingApprovals;
  final int approvedToday;
  final int rejectedToday;
  final int completedToday;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.todayVisitors,
    required this.pendingApprovals,
    required this.approvedToday,
    required this.rejectedToday,
    required this.completedToday,
    required this.lastUpdated,
  });

  DashboardStats.empty()
      : this(
          todayVisitors: 0,
          pendingApprovals: 0,
          approvedToday: 0,
          rejectedToday: 0,
          completedToday: 0,
          lastUpdated: DateTime.now(),
        );

  @override
  List<Object> get props => [
        todayVisitors,
        pendingApprovals,
        approvedToday,
        rejectedToday,
        completedToday,
        lastUpdated,
      ];
}