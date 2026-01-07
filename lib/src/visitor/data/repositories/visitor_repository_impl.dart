import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/visitor_repository.dart';
import '../datasources/visitor_remote_data_source.dart';

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
}