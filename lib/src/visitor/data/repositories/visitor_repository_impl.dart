import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/visitor_profile.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_remote_data_source.dart';
import '../models/visitor_profile_model.dart';

class VisitorRepositoryImpl implements VisitorRepository {
  final VisitorRemoteDataSource remoteDataSource;

  VisitorRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<Visitor> registerVisitor(Visitor visitor) async {
    try {
      // Convert domain entity to data model for storage
      final visitorModel = visitor as dynamic; // This would need proper conversion
      final result = await remoteDataSource.registerVisitor(visitorModel);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<Visitor>> getAllVisitors() async {
    try {
      final result = await remoteDataSource.getAllVisitors();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<Visitor>> getVisitorsForEmployee(String employeeId) async {
    try {
      final result = await remoteDataSource.getVisitorsForEmployee(employeeId);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<Visitor>> getVisitorsByStatus(VisitorStatus status) async {
    try {
      final result = await remoteDataSource.getVisitorsByStatus(status);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<Visitor> updateVisitorStatus(String visitorId, VisitorStatus status) async {
    try {
      final result = await remoteDataSource.updateVisitorStatus(visitorId, status);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<Visitor> getVisitorById(String visitorId) async {
    try {
      final result = await remoteDataSource.getVisitorById(visitorId);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<Visitor> updateVisitor(Visitor visitor) async {
    try {
      final visitorModel = visitor as dynamic; // This would need proper conversion
      final result = await remoteDataSource.updateVisitor(visitorModel);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultVoid deleteVisitor(String visitorId) async {
    try {
      await remoteDataSource.deleteVisitor(visitorId);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<Visitor>> getRecentVisitors() async {
    try {
      // Get visitors from last 30 days
      final result = await remoteDataSource.getAllVisitors();
      final recentVisitors = result.where((visitor) {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        return visitor.createdAt.isAfter(thirtyDaysAgo);
      }).toList();
      return Right(recentVisitors);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<Visitor>> getVisitorsByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      // This would ideally be implemented with Firestore queries for efficiency
      final result = await remoteDataSource.getAllVisitors();
      final filteredVisitors = result.where((visitor) {
        return visitor.createdAt.isAfter(startDate) && 
               visitor.createdAt.isBefore(endDate);
      }).toList();
      return Right(filteredVisitors);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<Visitor>> getVisitorHistoryByPhone(String phoneNumber) async {
    try {
      final result = await remoteDataSource.getVisitorHistoryByPhone(phoneNumber);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<VisitorProfile?> getVisitorProfileByPhone(String phoneNumber) async {
    try {
      final result = await remoteDataSource.getVisitorProfileByPhone(phoneNumber);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<VisitorProfile> createOrUpdateVisitorProfile(VisitorProfile visitorProfile) async {
    try {
      final profileModel = visitorProfile is VisitorProfileModel 
          ? visitorProfile 
          : VisitorProfileModel(
              id: visitorProfile.id,
              name: visitorProfile.name,
              phoneNumber: visitorProfile.phoneNumber,
              email: visitorProfile.email,
              photoUrl: visitorProfile.photoUrl,
              createdAt: visitorProfile.createdAt,
              updatedAt: visitorProfile.updatedAt,
              visits: visitorProfile.visits,
              notes: visitorProfile.notes,
            );
      final result = await remoteDataSource.createOrUpdateVisitorProfile(profileModel);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<VisitorProfile> addVisitToProfile(String phoneNumber, Visit visit) async {
    try {
      final visitModel = VisitModel(
        id: visit.id,
        origin: visit.origin,
        purpose: visit.purpose,
        employeeToMeetId: visit.employeeToMeetId,
        employeeToMeetName: visit.employeeToMeetName,
        status: visit.status,
        gatekeeperId: visit.gatekeeperId,
        gatekeeperName: visit.gatekeeperName,
        visitDate: visit.visitDate,
        updatedAt: visit.updatedAt,
        notes: visit.notes,
        expectedDuration: visit.expectedDuration,
      );
      final result = await remoteDataSource.addVisitToProfile(phoneNumber, visitModel);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  ResultFuture<List<VisitorProfile>> searchVisitors(String query) async {
    try {
      final result = await remoteDataSource.searchVisitors(query);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 'unknown'));
    }
  }

  @override
  Stream<List<Visitor>> getVisitorsForEmployeeStream(String employeeId) {
    return remoteDataSource.getVisitorsForEmployeeStream(employeeId);
  }

  @override
  Stream<List<Visitor>> getVisitorsByStatusStream(VisitorStatus status) {
    return remoteDataSource.getVisitorsByStatusStream(status);
  }
}