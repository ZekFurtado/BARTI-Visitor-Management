import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../visitor/domain/entities/visitor.dart';
import '../models/dashboard_stats_model.dart';

abstract class DashboardRemoteDataSource {
  /// Get dashboard statistics for gatekeeper
  Future<DashboardStatsModel> getGatekeeperStats();

  /// Get dashboard statistics for employee
  Future<DashboardStatsModel> getEmployeeStats(String employeeId);

  /// Get today's visitor count
  Future<int> getTodayVisitorCount();

  /// Get pending approval count for an employee
  Future<int> getPendingApprovalsCount(String employeeId);

  /// Get total pending approvals (for gatekeeper view)
  Future<int> getTotalPendingApprovals();

  /// Get real-time dashboard statistics for gatekeeper
  Stream<DashboardStatsModel> getGatekeeperStatsStream();

  /// Get real-time dashboard statistics for employee
  Stream<DashboardStatsModel> getEmployeeStatsStream(String employeeId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;

  DashboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<DashboardStatsModel> getGatekeeperStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all visitor profiles to calculate statistics from visits
      final profilesQuery = await firestore
          .collection('visitor_profiles')
          .get();

      int todayVisitorsCount = 0;
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      int completedCount = 0;

      for (var profileDoc in profilesQuery.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final createdAt = (visitMap['createdAt'] as Timestamp?)?.toDate();
          
          if (createdAt != null && 
              createdAt.isAfter(startOfDay) && 
              createdAt.isBefore(endOfDay)) {
            todayVisitorsCount++;
            
            final status = parseVisitorStatus(visitMap['status'] as String?);
            switch (status) {
              case VisitorStatus.pending:
                pendingCount++;
                break;
              case VisitorStatus.approved:
                approvedCount++;
                break;
              case VisitorStatus.rejected:
                rejectedCount++;
                break;
              case VisitorStatus.completed:
                completedCount++;
                break;
            }
          }
        }
      }

      return DashboardStatsModel(
        todayVisitors: todayVisitorsCount,
        pendingApprovals: pendingCount,
        approvedToday: approvedCount,
        rejectedToday: rejectedCount,
        completedToday: completedCount,
        lastUpdated: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get gatekeeper stats',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<DashboardStatsModel> getEmployeeStats(String employeeId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all visitor profiles to calculate statistics from visits for this employee
      final profilesQuery = await firestore
          .collection('visitor_profiles')
          .get();

      int todayVisitorsCount = 0;
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      int completedCount = 0;

      for (var profileDoc in profilesQuery.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final employeeToMeetId = visitMap['employeeToMeetId'] as String?;
          
          // Only count visits for this specific employee
          if (employeeToMeetId == employeeId) {
            final status = parseVisitorStatus(visitMap['status'] as String?);
            
            // Count pending approvals (all time for this employee)
            if (status == VisitorStatus.pending) {
              pendingCount++;
            }
            
            // Count today's visitors for this employee
            final createdAt = (visitMap['createdAt'] as Timestamp?)?.toDate();
            if (createdAt != null && 
                createdAt.isAfter(startOfDay) && 
                createdAt.isBefore(endOfDay)) {
              todayVisitorsCount++;
              
              switch (status) {
                case VisitorStatus.approved:
                  approvedCount++;
                  break;
                case VisitorStatus.rejected:
                  rejectedCount++;
                  break;
                case VisitorStatus.completed:
                  completedCount++;
                  break;
                case VisitorStatus.pending:
                  // Already counted above
                  break;
              }
            }
          }
        }
      }

      return DashboardStatsModel(
        todayVisitors: todayVisitorsCount,
        pendingApprovals: pendingCount,
        approvedToday: approvedCount,
        rejectedToday: rejectedCount,
        completedToday: completedCount,
        lastUpdated: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get employee stats',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<int> getTodayVisitorCount() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all visitor profiles to count today's visits
      final profilesQuery = await firestore
          .collection('visitor_profiles')
          .get();

      int todayVisitorCount = 0;

      for (var profileDoc in profilesQuery.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final createdAt = (visitMap['createdAt'] as Timestamp?)?.toDate();
          
          if (createdAt != null && 
              createdAt.isAfter(startOfDay) && 
              createdAt.isBefore(endOfDay)) {
            todayVisitorCount++;
          }
        }
      }

      return todayVisitorCount;
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get today visitor count',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<int> getPendingApprovalsCount(String employeeId) async {
    try {
      // Get all visitor profiles to count pending visits for this employee
      final profilesQuery = await firestore
          .collection('visitor_profiles')
          .get();

      int pendingCount = 0;

      for (var profileDoc in profilesQuery.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final employeeToMeetId = visitMap['employeeToMeetId'] as String?;
          final status = visitMap['status'] as String?;
          
          if (employeeToMeetId == employeeId && status == 'pending') {
            pendingCount++;
          }
        }
      }

      return pendingCount;
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get pending approvals count',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Future<int> getTotalPendingApprovals() async {
    try {
      // Get all visitor profiles to count total pending visits
      final profilesQuery = await firestore
          .collection('visitor_profiles')
          .get();

      int totalPendingCount = 0;

      for (var profileDoc in profilesQuery.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final status = visitMap['status'] as String?;
          
          if (status == 'pending') {
            totalPendingCount++;
          }
        }
      }

      return totalPendingCount;
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get total pending approvals',
      );
    } on SocketException {
      throw const NetworkException(
        statusCode: '404',
        message: 'No Internet. Please check your network connection',
      );
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  @override
  Stream<DashboardStatsModel> getGatekeeperStatsStream() {
    return firestore
        .collection('visitor_profiles')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      int totalRegistered = 0;
      int pendingApprovals = 0;
      int approvedToday = 0;
      int rejectedToday = 0;
      int completedToday = 0;

      for (final profileDoc in snapshot.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final createdAt = (visitMap['createdAt'] as Timestamp?)?.toDate();
          
          if (createdAt != null && 
              createdAt.isAfter(startOfDay) && 
              createdAt.isBefore(endOfDay)) {
            totalRegistered++;

            final status = parseVisitorStatus(visitMap['status'] as String?);
            switch (status) {
              case VisitorStatus.pending:
                pendingApprovals++;
                break;
              case VisitorStatus.approved:
                approvedToday++;
                break;
              case VisitorStatus.rejected:
                rejectedToday++;
                break;
              case VisitorStatus.completed:
                completedToday++;
                break;
            }
          }
        }
      }

      return DashboardStatsModel(
        todayVisitors: totalRegistered,
        pendingApprovals: pendingApprovals,
        approvedToday: approvedToday,
        rejectedToday: rejectedToday,
        completedToday: completedToday,
        lastUpdated: DateTime.now(),
      );
    }).handleError((error) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'Failed to get gatekeeper stats stream: $error',
      );
    });
  }

  @override
  Stream<DashboardStatsModel> getEmployeeStatsStream(String employeeId) {
    return firestore
        .collection('visitor_profiles')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      int totalToday = 0;
      int pendingApprovals = 0;
      int approvedToday = 0;
      int rejectedToday = 0;
      int completedToday = 0;

      for (final profileDoc in snapshot.docs) {
        final profileData = profileDoc.data();
        final visits = profileData['visits'] as List<dynamic>? ?? [];
        
        for (var visitData in visits) {
          final visitMap = visitData as Map<String, dynamic>;
          final employeeToMeetId = visitMap['employeeToMeetId'] as String?;
          
          // Only count visits for this specific employee
          if (employeeToMeetId == employeeId) {
            final status = parseVisitorStatus(visitMap['status'] as String?);
            
            // Count pending approvals (all time for this employee)
            if (status == VisitorStatus.pending) {
              pendingApprovals++;
            }
            
            // Count today's visitors for this employee
            final createdAt = (visitMap['createdAt'] as Timestamp?)?.toDate();
            if (createdAt != null && 
                createdAt.isAfter(startOfDay) && 
                createdAt.isBefore(endOfDay)) {
              totalToday++;

              switch (status) {
                case VisitorStatus.approved:
                  approvedToday++;
                  break;
                case VisitorStatus.rejected:
                  rejectedToday++;
                  break;
                case VisitorStatus.completed:
                  completedToday++;
                  break;
                case VisitorStatus.pending:
                  // Already counted above
                  break;
              }
            }
          }
        }
      }

      return DashboardStatsModel(
        todayVisitors: totalToday,
        pendingApprovals: pendingApprovals,
        approvedToday: approvedToday,
        rejectedToday: rejectedToday,
        completedToday: completedToday,
        lastUpdated: DateTime.now(),
      );
    }).handleError((error) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'Failed to get employee stats stream: $error',
      );
    });
  }
}
