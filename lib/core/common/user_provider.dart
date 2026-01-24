import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';

/// Manages user authentication state and organization context
/// Provides organization switching capabilities for multi-tenant support
class UserProvider extends ChangeNotifier {
  LocalUser? _user;
  Organization? _currentOrganization;

  LocalUser? get user => _user;
  Organization? get currentOrganization => _currentOrganization;

  /// Get the current user's role in the selected organization
  /// Returns null if no user or no organization selected
  String? get currentRole {
    if (_user == null || _currentOrganization == null) return null;
    return _user!.getRoleInOrg(_currentOrganization!.id);
  }

  /// Get the current user's job role in the selected organization
  String? get currentJobRole {
    if (_user == null || _currentOrganization == null) return null;
    return _user!.getJobRoleInOrg(_currentOrganization!.id);
  }

  /// Get the current user's department in the selected organization
  String? get currentDepartment {
    if (_user == null || _currentOrganization == null) return null;
    return _user!.getDepartmentInOrg(_currentOrganization!.id);
  }

  /// Check if current user is a gatekeeper in the current organization
  bool get isGatekeeper {
    if (_user == null || _currentOrganization == null) return false;
    return _user!.isGatekeeperInOrg(_currentOrganization!.id);
  }

  /// Check if current user is an employee in the current organization
  bool get isEmployee {
    if (_user == null || _currentOrganization == null) return false;
    return _user!.isEmployeeInOrg(_currentOrganization!.id);
  }

  /// Check if current user is an admin in the current organization
  bool get isAdmin {
    if (_user == null || _currentOrganization == null) return false;
    return _user!.isAdminInOrg(_currentOrganization!.id);
  }

  /// Initialize user (backward compatible method)
  void initUser(LocalUser? user) {
    if (_user != user) {
      _user = user;
      notifyListeners();
    }
  }

  /// Set user (backward compatible setter)
  set user(LocalUser? user) {
    if (_user != user) {
      _user = user;
      notifyListeners();
    }
  }

  /// Set the current organization context
  /// This should be called after successful tenant detection/selection
  void setCurrentOrganization(Organization organization) {
    if (_currentOrganization?.id != organization.id) {
      _currentOrganization = organization;
      log('Organization context set: ${organization.name} (${organization.id})',
          name: 'UserProvider');
      notifyListeners();
    }
  }

  /// Switch to a different organization
  /// Validates user has access and reinitializes Firebase with new config
  Future<void> switchOrganization(Organization newOrg) async {
    log('Attempting to switch to organization: ${newOrg.name}',
        name: 'UserProvider');

    // Verify user has access to this organization
    if (_user?.hasAccessToOrg(newOrg.id) != true) {
      throw OrganizationAccessException(
        'User does not have access to organization: ${newOrg.name}',
      );
    }

    try {
      // Reinitialize Firebase with new organization's config
      await _reinitializeFirebase(newOrg);

      // Update current organization context
      setCurrentOrganization(newOrg);

      log('Successfully switched to organization: ${newOrg.name}',
          name: 'UserProvider');
    } catch (e) {
      log('Error switching organization: $e', name: 'UserProvider');
      rethrow;
    }
  }

  /// Reinitialize Firebase with new organization's configuration
  /// This is called when switching between organizations
  Future<void> _reinitializeFirebase(Organization org) async {
    log('Reinitializing Firebase for organization: ${org.name}',
        name: 'UserProvider');

    try {
      // Step 1: Delete current Firebase app instance
      if (Firebase.apps.isNotEmpty) {
        final currentApp = Firebase.app();
        log('Deleting current Firebase app: ${currentApp.name}',
            name: 'UserProvider');
        await currentApp.delete();
      }

      // Step 2: Initialize Firebase with new organization's config
      final androidConfig = org.firebaseConfig.android;
      final iosConfig = org.firebaseConfig.ios;

      // Determine which config to use based on platform
      // In production, you would check Platform.isAndroid/isIOS
      // For now, prefer Android config if available
      final platformConfig = androidConfig ?? iosConfig;

      if (platformConfig == null) {
        throw OrganizationConfigException(
          'No Firebase configuration available for organization: ${org.name}',
        );
      }

      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: platformConfig.apiKey,
          appId: platformConfig.appId,
          messagingSenderId: platformConfig.messagingSenderId,
          projectId: platformConfig.projectId,
          storageBucket: platformConfig.storageBucket,
          iosClientId: platformConfig.iosClientId,
        ),
      );

      log('Firebase reinitialized successfully for project: ${platformConfig.projectId}',
          name: 'UserProvider');

      // Step 3: Firebase service instances are automatically recreated
      // No need to manually recreate FirebaseAuth, Firestore, Storage
      // They will be automatically available through Firebase.app()

    } catch (e) {
      log('Error reinitializing Firebase: $e', name: 'UserProvider');
      throw FirebaseReinitializationException(
        'Failed to reinitialize Firebase: $e',
      );
    }
  }

  /// Clear user and organization context (for logout)
  void clear() {
    _user = null;
    _currentOrganization = null;
    log('User and organization context cleared', name: 'UserProvider');
    notifyListeners();
  }

  /// Check if user belongs to multiple organizations
  bool get belongsToMultipleOrgs {
    return _user?.belongsToMultipleOrgs ?? false;
  }

  /// Get all organizations the user has access to
  List<String> get userOrganizationIds {
    return _user?.organizationIds ?? [];
  }
}

/// Exception thrown when user doesn't have access to an organization
class OrganizationAccessException implements Exception {
  final String message;
  OrganizationAccessException(this.message);

  @override
  String toString() => 'OrganizationAccessException: $message';
}

/// Exception thrown when organization configuration is invalid
class OrganizationConfigException implements Exception {
  final String message;
  OrganizationConfigException(this.message);

  @override
  String toString() => 'OrganizationConfigException: $message';
}

/// Exception thrown when Firebase reinitialization fails
class FirebaseReinitializationException implements Exception {
  final String message;
  FirebaseReinitializationException(this.message);

  @override
  String toString() => 'FirebaseReinitializationException: $message';
}
