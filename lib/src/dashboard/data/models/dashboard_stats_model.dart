import '../../domain/entities/dashboard_stats.dart';

/// Dashboard statistics model that extends the dashboard stats entity for data layer operations
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.todayVisitors,
    required super.pendingApprovals,
    required super.approvedToday,
    required super.rejectedToday,
    required super.completedToday,
    required super.lastUpdated,
  });

  /// Creates an empty dashboard stats model for testing
  DashboardStatsModel.empty() : super.empty();

  /// Creates a dashboard stats model from a Map (for API responses or calculations)
  factory DashboardStatsModel.fromMap(Map<String, dynamic> map) {
    return DashboardStatsModel(
      todayVisitors: map['todayVisitors'] as int? ?? 0,
      pendingApprovals: map['pendingApprovals'] as int? ?? 0,
      approvedToday: map['approvedToday'] as int? ?? 0,
      rejectedToday: map['rejectedToday'] as int? ?? 0,
      completedToday: map['completedToday'] as int? ?? 0,
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Converts the dashboard stats model to a Map for storage
  Map<String, dynamic> toMap() {
    return {
      'todayVisitors': todayVisitors,
      'pendingApprovals': pendingApprovals,
      'approvedToday': approvedToday,
      'rejectedToday': rejectedToday,
      'completedToday': completedToday,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Creates a copy of this dashboard stats model with updated values
  DashboardStatsModel copyWith({
    int? todayVisitors,
    int? pendingApprovals,
    int? approvedToday,
    int? rejectedToday,
    int? completedToday,
    DateTime? lastUpdated,
  }) {
    return DashboardStatsModel(
      todayVisitors: todayVisitors ?? this.todayVisitors,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      approvedToday: approvedToday ?? this.approvedToday,
      rejectedToday: rejectedToday ?? this.rejectedToday,
      completedToday: completedToday ?? this.completedToday,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}