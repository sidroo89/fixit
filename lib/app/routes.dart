import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/user/user_home_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String userHome = '/user-home';
  static const String adminDashboard = '/admin-dashboard';
  static const String createTicket = '/create-ticket';
  static const String ticketDetails = '/ticket-details';
  static const String profile = '/profile';
  static const String notifications = '/notifications';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);

      case login:
        return _buildRoute(const LoginScreen(), settings);

      case register:
        return _buildRoute(const RegisterScreen(), settings);

      case userHome:
        return _buildRoute(const UserHomeScreen(), settings);

      case adminDashboard:
        return _buildRoute(const AdminDashboardScreen(), settings);

      // TODO: Add more routes in future phases
      // case createTicket:
      //   return _buildRoute(const CreateTicketScreen(), settings);
      //
      // case ticketDetails:
      //   final ticketId = settings.arguments as String;
      //   return _buildRoute(TicketDetailsScreen(ticketId: ticketId), settings);
      //
      // case profile:
      //   return _buildRoute(const ProfileScreen(), settings);
      //
      // case notifications:
      //   return _buildRoute(const NotificationsScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  // Helper method to build routes with transitions
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Navigation helper methods
  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }
}

