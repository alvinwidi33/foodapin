import 'package:flutter/material.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_state.dart';
import 'package:foodapin/features/authentication/signin/pages/signin_page.dart';
import 'package:foodapin/features/authentication/signup/pages/signup_page.dart';
import 'package:foodapin/features/user/home/pages/home_page.dart';

class AppRoutes {
  final AuthState authState;

  AppRoutes(this.authState);

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    const publicRoutes = [
      '/signin',
      '/signup',
    ];

    // Kalau belum login dan akses halaman private
    if (authState.status == AuthStatus.unauthenticated &&
        !publicRoutes.contains(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => const SigninPage(),
      );
    }

    switch (settings.name) {
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SigninPage());

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());

      // case '/dashboard':
      //   return MaterialPageRoute(builder: (_) => const DashboardPage());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
