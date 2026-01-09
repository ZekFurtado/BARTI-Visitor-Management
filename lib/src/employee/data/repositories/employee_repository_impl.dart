import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_data_source.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl(this.remoteDataSource);

  @override
  ResultFuture<List<Employee>> getAllEmployees() async {
    try {
      final result = await remoteDataSource.getAllEmployees();
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
  ResultFuture<Employee> getEmployeeById(String id) async {
    try {
      final result = await remoteDataSource.getEmployeeById(id);
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
  ResultFuture<List<Employee>> searchEmployees(String query) async {
    try {
      final result = await remoteDataSource.searchEmployees(query);
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
  ResultFuture<List<Employee>> getEmployeesByDepartment(String department) async {
    try {
      final result = await remoteDataSource.getEmployeesByDepartment(department);
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