import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_management/core/common/user_provider.dart';
import 'package:visitor_management/core/services/background_service.dart';
import 'package:visitor_management/core/services/injection_container.dart' as di;
import 'package:visitor_management/core/services/notification_service.dart';
import 'package:visitor_management/core/services/tenant_config_service.dart';
import 'package:visitor_management/core/utils/routes.dart';
import 'package:visitor_management/core/utils/theme.dart';
import 'package:visitor_management/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:visitor_management/src/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:visitor_management/src/employee/presentation/bloc/employee_bloc.dart';
import 'package:visitor_management/src/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:visitor_management/src/organization/domain/entities/organization.dart';
import 'package:visitor_management/src/organization/presentation/pages/subdomain_entry_app.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_history_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_profile_bloc.dart';

/// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  try {
    await Firebase.initializeApp();
  } catch (e) {
    log('Firebase already initialized or error: $e', name: 'BackgroundHandler');
  }

  log('🔔 Handling background message: ${message.messageId}',
      name: 'BackgroundHandler');
  log('🔔 Background message data: ${message.data}', name: 'BackgroundHandler');
  log('🔔 Background notification: ${message.notification?.title} - ${message.notification?.body}',
      name: 'BackgroundHandler');

  // Show notification immediately for background messages
  if (message.notification != null) {
    // This will be handled by the system and shown automatically
    log('✅ Background notification will be displayed by system',
        name: 'BackgroundHandler');
  }
}

/// Main entry point with multi-tenant support
/// Detects organization subdomain and initializes Firebase dynamically
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log('🚀 E-Pravesh starting...', name: 'Main');

  // STEP 1: Initialize minimal services
  final prefs = await SharedPreferences.getInstance();
  final tenantService = TenantConfigService(
    prefs: prefs,
    httpClient: http.Client(),
  );

  log('✅ Initialized SharedPreferences and TenantConfigService', name: 'Main');

  // STEP 2: Detect tenant subdomain
  String? subdomain;
  try {
    subdomain = await tenantService.detectSubdomain();
    log('✅ Subdomain detected: $subdomain', name: 'Main');
  } catch (e) {
    log('⚠️ No subdomain configured, showing entry screen', name: 'Main');
    // Show subdomain entry screen
    runApp(SubdomainEntryApp(tenantService: tenantService));
    return;
  }

  // STEP 3: Fetch organization configuration from registry
  Organization? organization;
  try {
    organization = await tenantService.fetchTenantConfig(subdomain);
    log('✅ Organization config loaded: ${organization.name}', name: 'Main');
  } catch (e) {
    log('❌ Failed to load organization config: $e', name: 'Main');
    // Show error screen
    runApp(TenantConfigErrorApp(error: e));
    return;
  }

  // STEP 4: Initialize Firebase with tenant-specific config
  try {
    // Determine which platform config to use
    final platformConfig = organization.firebaseConfig.android ??
        organization.firebaseConfig.ios;

    if (platformConfig == null) {
      throw Exception(
        'No Firebase configuration available for ${organization.name}',
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

    log('✅ Firebase initialized for project: ${platformConfig.projectId}',
        name: 'Main');
  } catch (e) {
    log('❌ Failed to initialize Firebase: $e', name: 'Main');
    runApp(TenantConfigErrorApp(
      error: 'Firebase initialization failed: $e',
    ));
    return;
  }

  // STEP 5: Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // STEP 6: Initialize dependency injection with organization context
  try {
    await di.init(organization: organization);
    log('✅ Dependency injection initialized', name: 'Main');
  } catch (e) {
    log('❌ Failed to initialize dependencies: $e', name: 'Main');
    runApp(TenantConfigErrorApp(
      error: 'Dependency initialization failed: $e',
    ));
    return;
  }

  // STEP 7: Initialize background service
  try {
    await BackgroundService.initialize();
    log('✅ Background service initialized', name: 'Main');
  } catch (e) {
    log('⚠️ Background service initialization failed: $e', name: 'Main');
    // Non-fatal, continue
  }

  // STEP 8: Initialize notification service
  try {
    final notificationService = di.sl<NotificationService>();
    await notificationService.initialize();
    NotificationService.setNavigatorKey(navigatorKey);
    log('✅ Notification service initialized', name: 'Main');
  } catch (e) {
    log('⚠️ Notification service initialization failed: $e', name: 'Main');
    // Non-fatal, continue
  }

  // STEP 9: Launch app with organization context
  log('🎉 Launching E-Pravesh for ${organization.name}', name: 'Main');
  runApp(MyApp(organization: organization));
}

/// Main application widget with organization context
class MyApp extends StatelessWidget {
  final Organization organization;

  const MyApp({
    super.key,
    required this.organization,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider()..setCurrentOrganization(organization),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<AuthenticationBloc>()),
          BlocProvider(create: (context) => di.sl<VisitorBloc>()),
          BlocProvider(create: (context) => di.sl<VisitorHistoryBloc>()),
          BlocProvider(create: (context) => di.sl<DashboardBloc>()),
          BlocProvider(create: (context) => di.sl<EmployeeBloc>()),
          BlocProvider(create: (context) => di.sl<VisitorProfileBloc>()),
          BlocProvider(create: (context) => di.sl<NotificationsBloc>()),
        ],
        child: MaterialApp(
          title: organization.branding.appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            colorScheme: organization.branding.toColorScheme(),
            textTheme: AppTheme.textTheme,
            useMaterial3: true,
          ),
          initialRoute: Routes.splash,
          routes: Routes.routes,
          onGenerateRoute: Routes.onGenerateRoute,
        ),
      ),
    );
  }
}


