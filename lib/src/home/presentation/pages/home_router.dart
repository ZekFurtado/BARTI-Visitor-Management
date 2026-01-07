import 'package:flutter/material.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/home/presentation/pages/employee_home.dart';
import 'package:visitor_management/src/home/presentation/pages/gatekeeper_home.dart';

class HomeRouter extends StatelessWidget {
  const HomeRouter({super.key, required this.user});

  final LocalUser user;

  @override
  Widget build(BuildContext context) {
    // Route user to appropriate home screen based on role
    switch (user.role?.toLowerCase()) {
      case 'gatekeeper':
        return GatekeeperHome(user: user);
      case 'employee':
        return EmployeeHome(user: user);
      default:
        // Fallback for users without proper role assignment
        return _buildRoleNotFoundScreen(context);
    }
  }

  Widget _buildRoleNotFoundScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BARTI'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Role Not Assigned',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your account does not have a proper role assigned. Please contact the administrator to assign a role (Gatekeeper or Employee).',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'User Details:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${user.name ?? 'Not provided'}'),
                      Text('Email: ${user.email ?? 'Not provided'}'),
                      Text('Role: ${user.role ?? 'Not assigned'}'),
                      if (user.jobRole != null) Text('Job Role: ${user.jobRole}'),
                      if (user.department != null) Text('Department: ${user.department}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}