import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<DashboardStats> getGatekeeperStats() async {
    try {
      final result = await remoteDataSource.getGatekeeperStats();
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
  ResultFuture<DashboardStats> getEmployeeStats(String employeeId) async {
    try {
      final result = await remoteDataSource.getEmployeeStats(employeeId);
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
  ResultFuture<int> getTodayVisitorCount() async {
    try {
      final result = await remoteDataSource.getTodayVisitorCount();
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
  ResultFuture<int> getPendingApprovalsCount(String employeeId) async {
    try {
      final result = await remoteDataSource.getPendingApprovalsCount(employeeId);
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
  ResultFuture<int> getTotalPendingApprovals() async {
    try {
      final result = await remoteDataSource.getTotalPendingApprovals();
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