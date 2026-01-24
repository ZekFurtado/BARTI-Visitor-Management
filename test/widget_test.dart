// Multi-tenancy E-Pravesh widget tests
//
// These tests verify the multi-tenant functionality of the app

import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management/core/services/tenant_config_service_demo.dart';
import 'package:visitor_management/main.dart';

void main() {
  testWidgets('MyApp initializes with organization', (WidgetTester tester) async {
    // Create a test organization
    final testOrg = TenantConfigServiceDemo.getBARTIDemo();

    // Build our app with organization and trigger a frame
    await tester.pumpWidget(MyApp(organization: testOrg));

    // Verify that the app initializes without errors
    expect(find.byType(MyApp), findsOneWidget);

    // Note: Full navigation tests require Firebase initialization
    // which is complex in a test environment. For now, we verify
    // the app widget can be instantiated with an organization.
  });

  testWidgets('Demo organizations are available', (WidgetTester tester) async {
    // Verify all demo organizations can be created
    final bartiOrg = TenantConfigServiceDemo.getDemoOrganization('barti');
    expect(bartiOrg, isNotNull);
    expect(bartiOrg?.name, 'BARTI');

    final demoOrg = TenantConfigServiceDemo.getDemoOrganization('demo');
    expect(demoOrg, isNotNull);
    expect(demoOrg?.name, 'Demo Organization');

    final testOrg = TenantConfigServiceDemo.getDemoOrganization('test');
    expect(testOrg, isNotNull);
    expect(testOrg?.name, 'Test Organization');
  });

  test('Organization features differ by tier', () {
    final bartiOrg = TenantConfigServiceDemo.getBARTIDemo();
    final demoOrg = TenantConfigServiceDemo.getDemoOrganization('demo')!;
    final testOrg = TenantConfigServiceDemo.getDemoOrganization('test')!;

    // BARTI (Enterprise) should have all features
    expect(bartiOrg.features.smsNotifications, true);
    expect(bartiOrg.features.customFields, true);
    expect(bartiOrg.features.apiAccessEnabled, true);

    // Demo (Basic) should have some features
    expect(demoOrg.features.smsNotifications, true);
    expect(demoOrg.features.customFields, true);
    expect(demoOrg.features.apiAccessEnabled, false);

    // Test (Free) should have limited features
    expect(testOrg.features.smsNotifications, false);
    expect(testOrg.features.customFields, false);
    expect(testOrg.features.apiAccessEnabled, false);
  });

  test('Organization branding differs', () {
    final bartiOrg = TenantConfigServiceDemo.getBARTIDemo();
    final demoOrg = TenantConfigServiceDemo.getDemoOrganization('demo')!;
    final testOrg = TenantConfigServiceDemo.getDemoOrganization('test')!;

    // Different app names
    expect(bartiOrg.branding.appName, 'E-Pravesh - BARTI');
    expect(demoOrg.branding.appName, 'E-Pravesh Demo');
    expect(testOrg.branding.appName, 'E-Pravesh Test');

    // Different primary colors
    expect(bartiOrg.branding.primaryColor.value, 0xFFFA5013); // Orange
    expect(demoOrg.branding.primaryColor.value, 0xFF2196F3); // Blue
    expect(testOrg.branding.primaryColor.value, 0xFF4CAF50); // Green
  });
}
