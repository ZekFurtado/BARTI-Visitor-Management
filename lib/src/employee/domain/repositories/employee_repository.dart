import '../../../../core/utils/typedef.dart';
import '../entities/employee.dart';

/// Abstract repository for employee operations
abstract class EmployeeRepository {
  /// Get all active employees
  ResultFuture<List<Employee>> getAllEmployees();
  
  /// Get employee by ID
  ResultFuture<Employee> getEmployeeById(String id);
  
  /// Search employees by name, department, or job role
  ResultFuture<List<Employee>> searchEmployees(String query);
  
  /// Get employees by department
  ResultFuture<List<Employee>> getEmployeesByDepartment(String department);
}