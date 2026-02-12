import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/app_routes.dart';
import 'package:foodapin/components/app_theme.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/data/repositories/payment_method_repository/payment_method_repository.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_cubit.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_state.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_bloc.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_bloc.dart';
import 'package:foodapin/features/user/home/bloc/home_bloc.dart';

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CartRepository cartRepository;
  final FoodRepository foodRepository;
  final PaymentMethodRepository paymentMethodRepository;
  final RatingRepository ratingRepository;
  final TransactionRepository transactionRepository;
  final UserRepository userRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.cartRepository,
    required this.foodRepository,
    required this.paymentMethodRepository,
    required this.ratingRepository,
    required this.transactionRepository,
    required this.userRepository,
  });

  @override
Widget build(BuildContext context) {
  return BlocBuilder<AuthCubit, AuthState>(
    builder: (context, authState) {
      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: cartRepository),
          RepositoryProvider.value(value: foodRepository),
          RepositoryProvider.value(value: paymentMethodRepository),
          RepositoryProvider.value(value: ratingRepository),
          RepositoryProvider.value(value: transactionRepository),
          RepositoryProvider.value(value: userRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => SignInBloc(
                authRepository: authRepository,
                userRepository: userRepository,
              ),
            ),
            BlocProvider(
              create: (_) => SignUpBloc(
                authRepository: authRepository,
                userRepository: userRepository,
              ),
            ),
            BlocProvider(
              create: (_) => HomeBloc(
                foodRepository: foodRepository
              ),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: '/signin',
            onGenerateRoute:
                AppRoutes(authState).onGenerateRoute,
          ),
        ),
      );
    },
  );
}

}