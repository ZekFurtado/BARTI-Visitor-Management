import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:visitor_management/core/services/injection_container.dart' as di;
import 'package:visitor_management/core/utils/firebase_options.dart';
import 'package:visitor_management/core/utils/theme.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/authentication/presentation/pages/login.dart';
import 'package:visitor_management/src/authentication/presentation/pages/registration.dart';
import 'package:visitor_management/src/home/presentation/pages/home_router.dart';
import 'package:visitor_management/src/visitor/presentation/pages/visitor_registration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BARTI Visitor Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: AppTheme.colorScheme,
        textTheme: AppTheme.textTheme,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments as LocalUser?;
          if (user != null) {
            return MaterialPageRoute(
              builder: (context) => HomeRouter(user: user),
            );
          } else {
            // If no user data, redirect to login
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
        } else if (settings.name == '/visitor_registration') {
          final gatekeeper = settings.arguments as LocalUser?;
          if (gatekeeper != null) {
            return MaterialPageRoute(
              builder: (context) => VisitorRegistrationScreen(gatekeeper: gatekeeper),
            );
          } else {
            // If no gatekeeper data, redirect to login
            return MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            );
          }
        }
        return null;
      },
    );
  }
}


