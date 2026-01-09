import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  /// Get all active employees
  Future<List<EmployeeModel>> getAllEmployees();
  
  /// Get employee by ID
  Future<EmployeeModel> getEmployeeById(String id);
  
  /// Search employees by name, department, or job role
  Future<List<EmployeeModel>> searchEmployees(String query);
  
  /// Get employees by department
  Future<List<EmployeeModel>> getEmployeesByDepartment(String department);
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final FirebaseFirestore firestore;

  EmployeeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<EmployeeModel>> getAllEmployees() async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get employees',
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
  Future<EmployeeModel> getEmployeeById(String id) async {
    try {
      final doc = await firestore.collection('users').doc(id).get();

      if (!doc.exists) {
        throw const ServerException(
          statusCode: '404',
          message: 'Employee not found',
        );
      }

      // Check if the user is actually an employee
      final data = doc.data()!;
      if (data['role'] != 'Employee') {
        throw const ServerException(
          statusCode: '403',
          message: 'User is not an employee',
        );
      }

      return EmployeeModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get employee',
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
  Future<List<EmployeeModel>> searchEmployees(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllEmployees();
      }

      // Search by name (case insensitive)
      final nameQuery = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      // Search by department
      final departmentQuery = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('department', isGreaterThanOrEqualTo: query)
          .where('department', isLessThan: query + 'z')
          .get();

      // Search by job role
      final jobRoleQuery = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('jobRole', isGreaterThanOrEqualTo: query)
          .where('jobRole', isLessThan: query + 'z')
          .get();

      final results = <EmployeeModel>[];
      final addedIds = <String>{};

      // Add name search results
      for (final doc in nameQuery.docs) {
        final employee = EmployeeModel.fromFirestore(doc);
        if (!addedIds.contains(employee.id)) {
          results.add(employee);
          addedIds.add(employee.id);
        }
      }

      // Add department search results (avoiding duplicates)
      for (final doc in departmentQuery.docs) {
        final employee = EmployeeModel.fromFirestore(doc);
        if (!addedIds.contains(employee.id)) {
          results.add(employee);
          addedIds.add(employee.id);
        }
      }

      // Add job role search results (avoiding duplicates)
      for (final doc in jobRoleQuery.docs) {
        final employee = EmployeeModel.fromFirestore(doc);
        if (!addedIds.contains(employee.id)) {
          results.add(employee);
          addedIds.add(employee.id);
        }
      }

      // Sort results by name
      results.sort((a, b) => a.name.compareTo(b.name));

      return results;
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to search employees',
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
  Future<List<EmployeeModel>> getEmployeesByDepartment(String department) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Employee')
          .where('department', isEqualTo: department)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => EmployeeModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
        statusCode: e.code,
        message: e.message ?? 'Failed to get employees by department',
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
}