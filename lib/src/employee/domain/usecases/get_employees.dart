import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/employee.dart';
import '../repositories/employee_repository.dart';

/// Use case for getting all employees
class GetAllEmployees extends UseCaseWithoutParams<List<Employee>> {
  final EmployeeRepository repository;

  GetAllEmployees(this.repository);

  @override
  ResultFuture<List<Employee>> call() {
    return repository.getAllEmployees();
  }
}

/// Use case for getting employee by ID
class GetEmployeeById extends UseCaseWithParams<Employee, GetEmployeeByIdParams> {
  final EmployeeRepository repository;

  GetEmployeeById(this.repository);

  @override
  ResultFuture<Employee> call(GetEmployeeByIdParams params) {
    return repository.getEmployeeById(params.id);
  }
}

/// Parameters for getting employee by ID
class GetEmployeeByIdParams extends Equatable {
  final String id;

  const GetEmployeeByIdParams({required this.id});

  @override
  List<Object> get props => [id];
}

/// Use case for searching employees
class SearchEmployees extends UseCaseWithParams<List<Employee>, SearchEmployeesParams> {
  final EmployeeRepository repository;

  SearchEmployees(this.repository);

  @override
  ResultFuture<List<Employee>> call(SearchEmployeesParams params) {
    return repository.searchEmployees(params.query);
  }
}

/// Parameters for searching employees
class SearchEmployeesParams extends Equatable {
  final String query;

  const SearchEmployeesParams({required this.query});

  @override
  List<Object> get props => [query];
}

/// Use case for getting employees by department
class GetEmployeesByDepartment extends UseCaseWithParams<List<Employee>, GetEmployeesByDepartmentParams> {
  final EmployeeRepository repository;

  GetEmployeesByDepartment(this.repository);

  @override
  ResultFuture<List<Employee>> call(GetEmployeesByDepartmentParams params) {
    return repository.getEmployeesByDepartment(params.department);
  }
}

/// Parameters for getting employees by department
class GetEmployeesByDepartmentParams extends Equatable {
  final String department;

  const GetEmployeesByDepartmentParams({required this.department});

  @override
  List<Object> get props => [department];
}