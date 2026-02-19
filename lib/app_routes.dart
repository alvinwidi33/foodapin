import 'package:flutter/material.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_state.dart';
import 'package:foodapin/features/authentication/signin/pages/signin_page.dart';
import 'package:foodapin/features/authentication/signup/pages/signup_page.dart';
import 'package:foodapin/features/user/detail-food/page/detail_food_page.dart';
import 'package:foodapin/features/user/home/pages/home_page.dart';
import 'package:foodapin/features/user/my-cart/pages/cart_page.dart';
import 'package:foodapin/features/user/my-favourite/pages/my_fav_page.dart';
import 'package:foodapin/features/user/transaction-detail/pages/transaction_detail_page.dart';
import 'package:foodapin/features/user/transaction/pages/transaction_page.dart';
class AppRoutes {
  final AuthState authState;

  AppRoutes(this.authState);

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  const publicRoutes = [
    '/signin',
    '/signup',
  ];

  if (authState.status != AuthStatus.authenticated &&
      !publicRoutes.contains(settings.name)) {
    return MaterialPageRoute(
      builder: (_) => const SigninPage(),
    );
  }

  if (authState.status == AuthStatus.authenticated &&
      publicRoutes.contains(settings.name)) {
    return MaterialPageRoute(
      builder: (_) => const HomePage(),
    );
  }

  switch (settings.name) {
    case '/signin':
      return MaterialPageRoute(builder: (_) => const SigninPage());

    case '/signup':
      return MaterialPageRoute(builder: (_) => const SignupPage());

    case '/home':
      return MaterialPageRoute(builder: (_) => const HomePage());

    case '/detail-food':
      return MaterialPageRoute(
        builder: (_) => const DetailFoodPage(),
        settings: settings,
      );

    case '/my-cart':
      return MaterialPageRoute(builder: (_) => const CartPage());

    case '/my-transactions':
      return MaterialPageRoute(builder: (_) => const TransactionPage());

    case '/my-transaction-detail':
      return MaterialPageRoute(
        builder: (_) => const TransactionDetailPage(),
        settings: settings,
      );
    case '/my-likes':
      return MaterialPageRoute(builder: (_) => const MyFavPage());

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}

}
