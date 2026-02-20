import 'package:flutter/material.dart';
import 'package:foodapin/features/admin/create_foods/pages/create_food_page.dart';
import 'package:foodapin/features/admin/detail_food_admin/pages/detail_food_admin_page.dart';
import 'package:foodapin/features/admin/foods/pages/foods_page.dart';
import 'package:foodapin/features/admin/transactions/pages/all_transactions_page.dart';
import 'package:foodapin/features/admin/update_food/pages/update_food_page.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_state.dart';
import 'package:foodapin/features/authentication/signin/pages/signin_page.dart';
import 'package:foodapin/features/authentication/signup/pages/signup_page.dart';
import 'package:foodapin/features/profile/pages/profile_page.dart';
import 'package:foodapin/features/user/detail_food/page/detail_food_page.dart';
import 'package:foodapin/features/user/home/pages/home_page.dart';
import 'package:foodapin/features/user/my_cart/pages/cart_page.dart';
import 'package:foodapin/features/user/my-favourite/pages/my_fav_page.dart';
import 'package:foodapin/features/user/transaction_detail/pages/transaction_detail_page.dart';
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
    
    case '/foods':
      return MaterialPageRoute(builder: (_) => const FoodsPage());

    case '/add-food':
      return MaterialPageRoute(builder: (_) => const CreateFoodPage());

    case '/food':
      return MaterialPageRoute(builder: (_) => const DetailFoodAdminPage(), settings: settings);
    
    case '/update-food':
      return MaterialPageRoute(builder: (_) => const UpdateFoodPage(), settings: settings);

    case '/transactions':
      return MaterialPageRoute(builder: (_) => const AllTransactionsPage());

    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfilePage());

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );
  }
}

}
