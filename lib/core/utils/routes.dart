import 'package:flutter/material.dart';
import 'package:visitor_management/src/authentication/domain/entities/user.dart';
import 'package:visitor_management/src/authentication/presentation/pages/login.dart';
import 'package:visitor_management/src/authentication/presentation/pages/registration.dart';
import 'package:visitor_management/src/authentication/presentation/pages/splash_screen.dart';
import 'package:visitor_management/src/home/presentation/pages/home_router.dart';
import 'package:visitor_management/src/visitor/presentation/pages/visitor_registration.dart';
import 'package:visitor_management/src/visitor/presentation/pages/visitor_history_screen.dart';
import 'package:visitor_management/src/visitor/presentation/pages/pending_visitors_screen.dart';
import 'package:visitor_management/src/notifications/presentation/pages/notifications_screen.dart';

class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String home = '/home';
  static const String visitorRegistration = '/visitor_registration';
  static const String visitorHistory = '/visitor_history';
  static const String pendingVisitors = '/pending_visitors';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        final user = settings.arguments as LocalUser?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (context) => HomeRouter(user: user),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: login),
          );
        }

      case visitorRegistration:
        final gatekeeper = settings.arguments as LocalUser?;
        if (gatekeeper != null) {
          return MaterialPageRoute(
            builder: (context) => VisitorRegistrationScreen(gatekeeper: gatekeeper),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: login),
          );
        }

      case visitorHistory:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null && args.containsKey('userRole') && args.containsKey('userId')) {
          return MaterialPageRoute(
            builder: (context) => VisitorHistoryScreen(
              userRole: args['userRole'] as String,
              userId: args['userId'] as String,
            ),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: login),
          );
        }

      case pendingVisitors:
        final user = settings.arguments as LocalUser?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (context) => PendingVisitorsScreen(user: user),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: login),
          );
        }

      case notifications:
        final user = settings.arguments as LocalUser?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (context) => NotificationsScreen(user: user),
            settings: settings,
          );
        } else {
          return MaterialPageRoute(
            builder: (context) => const LoginScreen(),
            settings: const RouteSettings(name: login),
          );
        }

      default:
        return null;
    }
  }
}
