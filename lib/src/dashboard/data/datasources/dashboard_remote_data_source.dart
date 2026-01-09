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

      // Get all visitors for today
      final todayVisitorsQuery = await firestore
          .collection('visitors')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final todayVisitors = todayVisitorsQuery.docs;

      // Count by status
      int pendingCount = 0;
      int approvedCount = 0;
      int rejectedCount = 0;
      int completedCount = 0;

      for (var doc in todayVisitors) {
        final status = parseVisitorStatus(doc.data()['status'] as String?);
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

      return DashboardStatsModel(
        todayVisitors: todayVisitors.length,
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

      // Get visitors for this employee for today
      final employeeVisitorsQuery = await firestore
          .collection('visitors')
          .where('employeeToMeetId', isEqualTo: employeeId)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final employeeVisitors = employeeVisitorsQuery.docs;

      // Count pending approvals for this employee
      final pendingQuery = await firestore
          .collection('visitors')
          .where('employeeToMeetId', isEqualTo: employeeId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Count by status for today
      int approvedCount = 0;
      int rejectedCount = 0;
      int completedCount = 0;

      for (var doc in employeeVisitors) {
        final status = parseVisitorStatus(doc.data()['status'] as String?);
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
            break; // Already counted separately
        }
      }

      return DashboardStatsModel(
        todayVisitors: employeeVisitors.length,
        pendingApprovals: pendingQuery.docs.length,
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

      final query = await firestore
          .collection('visitors')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return query.docs.length;
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
      final query = await firestore
          .collection('visitors')
          .where('employeeToMeetId', isEqualTo: employeeId)
          .where('status', isEqualTo: 'pending')
          .get();

      return query.docs.length;
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
      final query = await firestore
          .collection('visitors')
          .where('status', isEqualTo: 'pending')
          .get();

      return query.docs.length;
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
    try {
      return firestore.collection('visitor_profiles').snapshots().map((
        snapshot,
      ) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        int totalRegistered = 0;
        int pendingApprovals = 0;
        int approvedToday = 0;
        int rejectedToday = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final visits = List<Map<String, dynamic>>.from(data['visits'] ?? []);

          for (final visitData in visits) {
            final visitDate = (visitData['visitDate'] as Timestamp?)?.toDate();
            if (visitDate != null && visitDate.isAfter(startOfDay)) {
              totalRegistered++;

              final status = visitData['status'] as String?;
              switch (status) {
                case 'pending':
                  pendingApprovals++;
                  break;
                case 'approved':
                  approvedToday++;
                  break;
                case 'rejected':
                  rejectedToday++;
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
          completedToday: 0,
          lastUpdated: DateTime.now(),
        );
      });
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'Failed to get gatekeeper stats stream: $e',
      );
    }
  }

  @override
  Stream<DashboardStatsModel> getEmployeeStatsStream(String employeeId) {
    try {
      return firestore.collection('visitor_profiles').snapshots().map((
        snapshot,
      ) {
        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        int pendingApprovals = 0;
        int approvedToday = 0;
        int rejectedToday = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final visits = List<Map<String, dynamic>>.from(data['visits'] ?? []);

          for (final visitData in visits) {
            if (visitData['employeeToMeetId'] == employeeId) {
              final visitDate = (visitData['visitDate'] as Timestamp?)
                  ?.toDate();
              if (visitDate != null && visitDate.isAfter(startOfDay)) {
                final status = visitData['status'] as String?;
                switch (status) {
                  case 'pending':
                    pendingApprovals++;
                    break;
                  case 'approved':
                    approvedToday++;
                    break;
                  case 'rejected':
                    rejectedToday++;
                    break;
                }
              }
            }
          }
        }

        return DashboardStatsModel(
          todayVisitors: pendingApprovals + approvedToday + rejectedToday,
          pendingApprovals: pendingApprovals,
          approvedToday: approvedToday,
          rejectedToday: rejectedToday,
          completedToday: 0,
          lastUpdated: DateTime.now(),
        );
      });
    } catch (e) {
      throw ServerException(
        statusCode: 'unknown',
        message: 'Failed to get employee stats stream: $e',
      );
    }
  }
}
