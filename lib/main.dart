import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management/core/services/injection_container.dart' as di;
import 'package:visitor_management/core/services/notification_service.dart';
import 'package:visitor_management/core/utils/firebase_options.dart';
import 'package:visitor_management/core/utils/routes.dart';
import 'package:visitor_management/core/utils/theme.dart';
import 'package:visitor_management/src/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:visitor_management/src/employee/presentation/bloc/employee_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_history_bloc.dart';
import 'package:visitor_management/src/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:visitor_management/src/visitor/presentation/bloc/visitor_profile_bloc.dart';

import 'core/common/user_provider.dart';

/// Global navigator key for navigation from notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  
  // Initialize notification service and set navigator key
  final notificationService = di.sl<NotificationService>();
  await notificationService.initialize();
  NotificationService.setNavigatorKey(navigatorKey);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<AuthenticationBloc>()),
          BlocProvider(create: (context) => di.sl<VisitorBloc>()),
          BlocProvider(create: (context) => di.sl<VisitorHistoryBloc>()),
          BlocProvider(create: (context) => di.sl<DashboardBloc>()),
          BlocProvider(create: (context) => di.sl<EmployeeBloc>()),
          BlocProvider(create: (context) => di.sl<VisitorProfileBloc>()),
        ],
        child: MaterialApp(
          title: 'BARTI Visitor Management',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            colorScheme: AppTheme.colorScheme,
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


