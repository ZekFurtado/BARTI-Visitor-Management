import 'package:flutter/material.dart';
import 'package:visitor_management/src/organization/data/models/branding_config_model.dart';
import 'package:visitor_management/src/organization/data/models/feature_config_model.dart';
import 'package:visitor_management/src/organization/data/models/firebase_config_model.dart';
import 'package:visitor_management/src/organization/data/models/organization_model.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';

/// Demo/Mock tenant configuration for local testing
/// Use this when the registry Firebase project is not yet set up
class TenantConfigServiceDemo {
  /// Get demo BARTI organization configuration
  /// This uses the existing Firebase project credentials
  static Organization getBARTIDemo() {
    return OrganizationModel(
      id: 'barti_demo_id',
      subdomain: 'barti',
      name: 'BARTI',
      status: OrganizationStatus.active,
      firebaseConfig: FirebaseConfigModel(
        android: FirebasePlatformConfigModel(
          apiKey: 'AIzaSyANl6YGWI1aUHQohTiVi8b_bKaqMd9pikk',
          appId: '1:332690330592:android:6b8cdd21de8baaf41b1185',
          messagingSenderId: '332690330592',
          projectId: 'visitor-management-e97f4',
          storageBucket: 'visitor-management-e97f4.firebasestorage.app',
        ),
        ios: FirebasePlatformConfigModel(
          apiKey: 'AIzaSyAUbEPbej5pombNE_57KIQNOUYQvUtrWLs',
          appId: '1:332690330592:ios:3de62faef7bec0601b1185',
          messagingSenderId: '332690330592',
          projectId: 'visitor-management-e97f4',
          storageBucket: 'visitor-management-e97f4.firebasestorage.app',
          iosBundleId: 'com.example.visitorManagement',
        ),
      ),
      branding: const BrandingConfigModel(
        primaryColor: Color(0xFFFA5013),
        secondaryColor: Color(0xFF2C3E50),
        appName: 'E-Pravesh - BARTI',
        tagline: 'Dr. Babasaheb Ambedkar Research and Training Institute',
      ),
      features: const FeatureConfigModel.enterpriseTier(),
      visitorCustomFields: const [],
      employeeCustomFields: const [],
      email: 'info@barti.org',
      phone: '+91-1234567890',
      website: 'https://barti.org',
      createdAt: DateTime.now(),
      subscriptionPlan: SubscriptionPlan.enterprise,
    );
  }

  /// Get demo organization by subdomain
  /// For testing multiple organizations
  static Organization? getDemoOrganization(String subdomain) {
    switch (subdomain.toLowerCase()) {
      case 'barti':
        return getBARTIDemo();
      case 'demo':
        return _getDemoOrganization();
      case 'test':
        return _getTestOrganization();
      default:
        return null;
    }
  }

  /// Demo organization with basic features
  static Organization _getDemoOrganization() {
    return OrganizationModel(
      id: 'demo_org_id',
      subdomain: 'demo',
      name: 'Demo Organization',
      status: OrganizationStatus.trial,
      firebaseConfig: FirebaseConfigModel(
        android: FirebasePlatformConfigModel(
          apiKey: 'AIzaSyANl6YGWI1aUHQohTiVi8b_bKaqMd9pikk',
          appId: '1:332690330592:android:6b8cdd21de8baaf41b1185',
          messagingSenderId: '332690330592',
          projectId: 'visitor-management-e97f4',
          storageBucket: 'visitor-management-e97f4.firebasestorage.app',
        ),
      ),
      branding: const BrandingConfigModel(
        primaryColor: Color(0xFF2196F3),
        secondaryColor: Color(0xFFFFC107),
        appName: 'E-Pravesh Demo',
        tagline: 'Demo Visitor Management',
      ),
      features: const FeatureConfigModel.basicTier(),
      visitorCustomFields: const [],
      employeeCustomFields: const [],
      createdAt: DateTime.now(),
      subscriptionPlan: SubscriptionPlan.basic,
      trialEndsAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Test organization with free tier features
  static Organization _getTestOrganization() {
    return OrganizationModel(
      id: 'test_org_id',
      subdomain: 'test',
      name: 'Test Organization',
      status: OrganizationStatus.active,
      firebaseConfig: FirebaseConfigModel(
        android: FirebasePlatformConfigModel(
          apiKey: 'AIzaSyANl6YGWI1aUHQohTiVi8b_bKaqMd9pikk',
          appId: '1:332690330592:android:6b8cdd21de8baaf41b1185',
          messagingSenderId: '332690330592',
          projectId: 'visitor-management-e97f4',
          storageBucket: 'visitor-management-e97f4.firebasestorage.app',
        ),
      ),
      branding: const BrandingConfigModel(
        primaryColor: Color(0xFF4CAF50),
        secondaryColor: Color(0xFF8BC34A),
        appName: 'E-Pravesh Test',
        tagline: 'Test Environment',
      ),
      features: const FeatureConfigModel.freeTier(),
      visitorCustomFields: const [],
      employeeCustomFields: const [],
      createdAt: DateTime.now(),
      subscriptionPlan: SubscriptionPlan.free,
    );
  }
}
