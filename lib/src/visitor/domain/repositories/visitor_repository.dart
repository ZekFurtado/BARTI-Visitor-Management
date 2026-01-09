import '../../../../core/utils/typedef.dart';
import '../entities/visitor.dart';
import '../entities/visitor_profile.dart';

/// Abstract repository for visitor operations
abstract class VisitorRepository {
  /// Register a new visitor
  ResultFuture<Visitor> registerVisitor(Visitor visitor);

  /// Get all visitors (for gatekeeper view)
  ResultFuture<List<Visitor>> getAllVisitors();

  /// Get visitors for a specific employee
  ResultFuture<List<Visitor>> getVisitorsForEmployee(String employeeId);

  /// Get visitors by status
  ResultFuture<List<Visitor>> getVisitorsByStatus(VisitorStatus status);

  /// Update visitor status (approve/reject)
  ResultFuture<Visitor> updateVisitorStatus(String visitorId, VisitorStatus status);

  /// Get visitor by ID
  ResultFuture<Visitor> getVisitorById(String visitorId);

  /// Update visitor information
  ResultFuture<Visitor> updateVisitor(Visitor visitor);

  /// Delete visitor record
  ResultVoid deleteVisitor(String visitorId);

  /// Get recent visitors (last 30 days)
  ResultFuture<List<Visitor>> getRecentVisitors();

  /// Get visitors by date range
  ResultFuture<List<Visitor>> getVisitorsByDateRange(DateTime startDate, DateTime endDate);

  /// Get visitor history by phone number
  ResultFuture<List<Visitor>> getVisitorHistoryByPhone(String phoneNumber);

  /// Get visitor profile by phone number
  ResultFuture<VisitorProfile?> getVisitorProfileByPhone(String phoneNumber);

  /// Create or update visitor profile
  ResultFuture<VisitorProfile> createOrUpdateVisitorProfile(VisitorProfile visitorProfile);

  /// Add a new visit to existing visitor profile
  ResultFuture<VisitorProfile> addVisitToProfile(String phoneNumber, Visit visit);

  /// Search visitors by name or phone
  ResultFuture<List<VisitorProfile>> searchVisitors(String query);

  /// Get real-time stream of visitors for a specific employee
  Stream<List<Visitor>> getVisitorsForEmployeeStream(String employeeId);

  /// Get real-time stream of visitors by status
  Stream<List<Visitor>> getVisitorsByStatusStream(VisitorStatus status);
}