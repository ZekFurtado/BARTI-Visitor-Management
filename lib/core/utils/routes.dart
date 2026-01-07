import 'package:visitor_management/src/authentication/presentation/pages/login.dart';
import 'package:visitor_management/src/authentication/presentation/pages/login_new.dart';

class Routes {
  static var routes = {
    '/login': (context) => const LoginScreen(),
    '/loginNew': (context) => const LoginNew(),
  };
}
