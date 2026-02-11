import 'package:flutter/material.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_state.dart';
import 'package:foodapin/features/authentication/signin/pages/signin_page.dart';
import 'package:foodapin/features/authentication/signup/pages/signup_page.dart';
import 'package:foodapin/features/user/home/pages/home_page.dart';

class AppRoutes {
  final AuthStatus authStatus;

  AppRoutes(this.authStatus);

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    const publicRoutes = [
      '/signin',
      '/signup',
    ];

    if (authStatus == AuthStatus.unauthenticated &&
        !publicRoutes.contains(settings.name)) {
      return MaterialPageRoute(
        builder: (_) => const SigninPage(),
      );
    }

    switch (settings.name) {
      case '/signin':
        return MaterialPageRoute(
          builder: (_) => const SigninPage(),
        );

      case '/signup':
        return MaterialPageRoute(
          builder: (_) => const SignupPage(),
        );

      case '/home': 
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }
}
