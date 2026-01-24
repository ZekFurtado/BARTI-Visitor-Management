import 'dart:convert';
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_management/core/services/tenant_config_service_demo.dart';
import 'package:visitor_management/src/organization/data/models/organization_model.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';

/// Service for managing tenant configuration and resolution
/// Handles subdomain detection and fetching organization config from registry
class TenantConfigService {
  /// Enable demo mode for local testing without registry
  /// Set to true to use TenantConfigServiceDemo instead of calling registry
  static const bool _demoMode = true; // Change to false in production

  /// Registry Firebase project ID (centralized config store)
  static const String _registryProjectId = 'epravesh-tenant-registry';

  /// Registry Firebase configuration
  /// IMPORTANT: Replace with actual registry project credentials
  static const String _registryApiKey = 'YOUR_REGISTRY_API_KEY';
  static const String _registryAppId = 'YOUR_REGISTRY_APP_ID';
  static const String _registryMessagingSenderId = 'YOUR_REGISTRY_SENDER_ID';
  static const String _registryStorageBucket = 'YOUR_REGISTRY_BUCKET';

  /// SharedPreferences key for cached subdomain
  static const String _cachedSubdomainKey = 'tenant_subdomain';

  /// SharedPreferences key for cached organization config
  static const String _cachedOrgKey = 'cached_organization_config';

  /// SharedPreferences key for config cache timestamp
  static const String _cachedTimestampKey = 'config_cache_timestamp';

  /// Cache expiration duration (24 hours)
  static const Duration _cacheExpiration = Duration(hours: 24);

  final SharedPreferences prefs;
  final http.Client httpClient;

  TenantConfigService({
    required this.prefs,
    required this.httpClient,
  });

  /// Detect subdomain from cached value, deep link, or user input
  /// Throws TenantNotConfiguredException if subdomain not found
  Future<String> detectSubdomain() async {
    // Check cached subdomain
    final cachedSubdomain = prefs.getString(_cachedSubdomainKey);
    if (cachedSubdomain != null && cachedSubdomain.isNotEmpty) {
      log('Subdomain detected from cache: $cachedSubdomain',
          name: 'TenantConfigService');
      return cachedSubdomain;
    }

    // TODO: Implement deep link detection
    // If app launched via deep link (epravesh://subdomain or https://subdomain.epravesh.com)
    // extract subdomain from the URL

    // TODO: Implement QR code scan support
    // If app has QR code scanner, subdomain can be encoded in QR

    // No subdomain found - throw exception to show subdomain entry screen
    log('No subdomain found in cache', name: 'TenantConfigService');
    throw TenantNotConfiguredException(
      'No organization configured. Please enter your organization subdomain.',
    );
  }

  /// Save subdomain to cache for future app launches
  Future<void> saveSubdomain(String subdomain) async {
    await prefs.setString(_cachedSubdomainKey, subdomain.trim().toLowerCase());
    log('Subdomain saved to cache: $subdomain', name: 'TenantConfigService');
  }

  /// Clear cached subdomain (for logout or org switch)
  Future<void> clearSubdomain() async {
    await prefs.remove(_cachedSubdomainKey);
    await prefs.remove(_cachedOrgKey);
    await prefs.remove(_cachedTimestampKey);
    log('Subdomain cache cleared', name: 'TenantConfigService');
  }

  /// Fetch tenant configuration from registry Cloud Function
  /// Falls back to cache if network request fails
  /// In demo mode, uses TenantConfigServiceDemo instead
  Future<Organization> fetchTenantConfig(String subdomain) async {
    log('Fetching tenant config for subdomain: $subdomain',
        name: 'TenantConfigService');

    // Demo mode: Use local mock data
    if (_demoMode) {
      log('🔧 Demo mode enabled - using mock data', name: 'TenantConfigService');
      final demoOrg = TenantConfigServiceDemo.getDemoOrganization(subdomain);
      if (demoOrg != null) {
        // Cache the demo config
        await _cacheOrganizationConfig(demoOrg);
        log('✅ Demo organization loaded: ${demoOrg.name}',
            name: 'TenantConfigService');
        return demoOrg;
      } else {
        throw TenantNotFoundException(
          'Demo organization with subdomain "$subdomain" not found. '
          'Available: barti, demo, test',
        );
      }
    }

    try {
      // Check cache first (for offline support)
      final cachedConfig = await _loadCachedOrganizationConfig();
      if (cachedConfig != null &&
          cachedConfig.subdomain == subdomain &&
          _isCacheValid()) {
        log('Using cached organization config', name: 'TenantConfigService');
        return cachedConfig;
      }

      // Fetch from registry
      final organization = await _fetchFromRegistry(subdomain);

      // Cache the result
      await _cacheOrganizationConfig(organization);

      log('Successfully fetched and cached organization config',
          name: 'TenantConfigService');
      return organization;
    } catch (e) {
      log('Error fetching tenant config: $e', name: 'TenantConfigService');

      // Try to load from cache as fallback
      final cachedConfig = await _loadCachedOrganizationConfig();
      if (cachedConfig != null && cachedConfig.subdomain == subdomain) {
        log('Using stale cached config as fallback',
            name: 'TenantConfigService');
        return cachedConfig;
      }

      rethrow;
    }
  }

  /// Fetch organization config from registry Firebase Cloud Function
  Future<Organization> _fetchFromRegistry(String subdomain) async {
    FirebaseApp? registryApp;

    try {
      // Initialize registry Firebase app temporarily
      registryApp = await Firebase.initializeApp(
        name: 'registry',
        options: const FirebaseOptions(
          apiKey: _registryApiKey,
          appId: _registryAppId,
          messagingSenderId: _registryMessagingSenderId,
          projectId: _registryProjectId,
          storageBucket: _registryStorageBucket,
        ),
      );

      log('Registry Firebase app initialized', name: 'TenantConfigService');

      // Call Cloud Function to get tenant config
      final callable = FirebaseFunctions.instanceFor(app: registryApp)
          .httpsCallable('getTenantConfig');

      final result = await callable.call({
        'subdomain': subdomain.trim().toLowerCase(),
      });

      final data = result.data as Map<String, dynamic>?;
      if (data == null) {
        throw TenantConfigurationException(
          'No configuration found for subdomain: $subdomain',
        );
      }

      // Parse response into Organization entity
      final orgModel = OrganizationModel.fromJson(data);

      // Validate organization is active
      if (!orgModel.isActive) {
        throw TenantSuspendedException(
          'Organization "$subdomain" is ${orgModel.status.displayName}',
        );
      }

      return orgModel;
    } on FirebaseFunctionsException catch (e) {
      log('Firebase Functions error: ${e.code} - ${e.message}',
          name: 'TenantConfigService');

      if (e.code == 'not-found') {
        throw TenantNotFoundException(
          'Organization with subdomain "$subdomain" not found',
        );
      }

      throw TenantConfigurationException(
        'Failed to fetch tenant configuration: ${e.message}',
      );
    } finally {
      // Clean up registry app
      if (registryApp != null) {
        await registryApp.delete();
        log('Registry Firebase app deleted', name: 'TenantConfigService');
      }
    }
  }

  /// Cache organization configuration locally
  Future<void> _cacheOrganizationConfig(Organization org) async {
    try {
      final json = (org as OrganizationModel).toJson();
      final jsonString = jsonEncode(json);

      await prefs.setString(_cachedOrgKey, jsonString);
      await prefs.setInt(
        _cachedTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      log('Organization config cached successfully', name: 'TenantConfigService');
    } catch (e) {
      log('Error caching organization config: $e',
          name: 'TenantConfigService');
      // Non-fatal - continue without cache
    }
  }

  /// Load cached organization configuration
  Future<Organization?> _loadCachedOrganizationConfig() async {
    try {
      final cached = prefs.getString(_cachedOrgKey);
      if (cached == null || cached.isEmpty) {
        return null;
      }

      final json = jsonDecode(cached) as Map<String, dynamic>;
      return OrganizationModel.fromJson(json);
    } catch (e) {
      log('Error loading cached organization config: $e',
          name: 'TenantConfigService');
      return null;
    }
  }

  /// Check if cached configuration is still valid
  bool _isCacheValid() {
    final timestamp = prefs.getInt(_cachedTimestampKey);
    if (timestamp == null) return false;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final age = DateTime.now().difference(cachedTime);

    return age < _cacheExpiration;
  }

  /// Clear cached organization config (force refresh)
  Future<void> clearCache() async {
    await prefs.remove(_cachedOrgKey);
    await prefs.remove(_cachedTimestampKey);
    log('Organization config cache cleared', name: 'TenantConfigService');
  }

  /// Refresh organization configuration from registry
  Future<Organization> refreshConfig(String subdomain) async {
    await clearCache();
    return fetchTenantConfig(subdomain);
  }

  /// Validate subdomain format
  static bool isValidSubdomain(String subdomain) {
    if (subdomain.isEmpty) return false;

    // Subdomain must be lowercase alphanumeric with hyphens
    final regex = RegExp(r'^[a-z0-9]([a-z0-9-]*[a-z0-9])?$');
    return regex.hasMatch(subdomain) && subdomain.length <= 63;
  }

  /// Extract subdomain from URL (for deep link support)
  static String? extractSubdomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Handle custom scheme: epravesh://subdomain
      if (uri.scheme == 'epravesh') {
        return uri.host;
      }

      // Handle HTTPS: https://subdomain.epravesh.com
      if (uri.scheme == 'https' && uri.host.endsWith('.epravesh.com')) {
        final subdomain = uri.host.split('.').first;
        return isValidSubdomain(subdomain) ? subdomain : null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Exception thrown when no tenant configuration is found
class TenantNotConfiguredException implements Exception {
  final String message;

  TenantNotConfiguredException(this.message);

  @override
  String toString() => 'TenantNotConfiguredException: $message';
}

/// Exception thrown when tenant configuration cannot be loaded
class TenantConfigurationException implements Exception {
  final String message;

  TenantConfigurationException(this.message);

  @override
  String toString() => 'TenantConfigurationException: $message';
}

/// Exception thrown when tenant is not found in registry
class TenantNotFoundException implements Exception {
  final String message;

  TenantNotFoundException(this.message);

  @override
  String toString() => 'TenantNotFoundException: $message';
}

/// Exception thrown when tenant is suspended or inactive
class TenantSuspendedException implements Exception {
  final String message;

  TenantSuspendedException(this.message);

  @override
  String toString() => 'TenantSuspendedException: $message';
}
