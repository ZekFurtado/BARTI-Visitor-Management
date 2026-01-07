import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:visitor_management/src/employee/domain/entities/employee.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';

class EmployeeSearchDialog extends StatefulWidget {
  const EmployeeSearchDialog({super.key});

  @override
  State<EmployeeSearchDialog> createState() => _EmployeeSearchDialogState();
}

class _EmployeeSearchDialogState extends State<EmployeeSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Employee> _allEmployees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;

  // Mock employees for demonstration
  final List<Employee> _mockEmployees = [
    Employee(
      id: 'emp1',
      name: 'Dr. Rajesh Kumar',
      email: 'rajesh.kumar@barti.org',
      jobRole: 'Research Director',
      department: 'Research',
      phoneNumber: '+91-9876543210',
      officeLocation: 'Room 201, Research Block',
    ),
    Employee(
      id: 'emp2',
      name: 'Prof. Sunita Sharma',
      email: 'sunita.sharma@barti.org',
      jobRole: 'Training Head',
      department: 'Training',
      phoneNumber: '+91-9876543211',
      officeLocation: 'Room 105, Training Block',
    ),
    Employee(
      id: 'emp3',
      name: 'Dr. Amit Patel',
      email: 'amit.patel@barti.org',
      jobRole: 'Senior Research Officer',
      department: 'Research',
      phoneNumber: '+91-9876543212',
      officeLocation: 'Room 203, Research Block',
    ),
    Employee(
      id: 'emp4',
      name: 'Ms. Priya Singh',
      email: 'priya.singh@barti.org',
      jobRole: 'Administrative Officer',
      department: 'Administration',
      phoneNumber: '+91-9876543213',
      officeLocation: 'Room 301, Admin Block',
    ),
    Employee(
      id: 'emp5',
      name: 'Dr. Vikram Rao',
      email: 'vikram.rao@barti.org',
      jobRole: 'Assistant Director',
      department: 'Research',
      phoneNumber: '+91-9876543214',
      officeLocation: 'Room 205, Research Block',
    ),
    Employee(
      id: 'emp6',
      name: 'Ms. Kavitha Reddy',
      email: 'kavitha.reddy@barti.org',
      jobRole: 'Training Coordinator',
      department: 'Training',
      phoneNumber: '+91-9876543215',
      officeLocation: 'Room 107, Training Block',
    ),
    Employee(
      id: 'emp7',
      name: 'Mr. Arjun Gupta',
      email: 'arjun.gupta@barti.org',
      jobRole: 'IT Manager',
      department: 'IT',
      phoneNumber: '+91-9876543216',
      officeLocation: 'Room 401, IT Block',
    ),
    Employee(
      id: 'emp8',
      name: 'Dr. Meera Nair',
      email: 'meera.nair@barti.org',
      jobRole: 'Research Fellow',
      department: 'Research',
      phoneNumber: '+91-9876543217',
      officeLocation: 'Room 207, Research Block',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _allEmployees = _mockEmployees;
      _filteredEmployees = _mockEmployees;
      _isLoading = false;
    });
  }

  void _filterEmployees(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredEmployees = _allEmployees;
      } else {
        _filteredEmployees = _allEmployees.where((employee) {
          final nameLower = employee.name.toLowerCase();
          final jobRoleLower = employee.jobRole.toLowerCase();
          final departmentLower = employee.department.toLowerCase();
          final queryLower = query.toLowerCase();
          
          return nameLower.contains(queryLower) ||
                 jobRoleLower.contains(queryLower) ||
                 departmentLower.contains(queryLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_search,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select Employee',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterEmployees,
                decoration: InputDecoration(
                  hintText: 'Search by name, job role, or department...',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterEmployees('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Employee List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading employees...'),
                        ],
                      ),
                    )
                  : _filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No employees found',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search terms',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredEmployees.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            return _buildEmployeeListTile(employee);
                          },
                        ),
            ),

            // Cancel Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeListTile(Employee employee) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: employee.profilePictureUrl != null
            ? ClipOval(
                child: Image.network(
                  employee.profilePictureUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      employee.initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              )
            : Text(
                employee.initials,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        employee.name,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee.departmentAndRole,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (employee.officeLocation != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  employee.officeLocation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        log('Selected employee: ${employee.name}');
        // Convert Employee to LocalUser for compatibility
        final localUser = LocalUser(
          uid: employee.id,
          name: employee.name,
          email: employee.email,
          role: 'Employee',
          jobRole: employee.jobRole,
          department: employee.department,
          phone: employee.phoneNumber,
          profilePic: employee.profilePictureUrl,
        );
        Navigator.of(context).pop(localUser);
      },
    );
  }
}