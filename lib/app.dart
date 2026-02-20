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
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/admin/create_foods/bloc/create_food_bloc.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/delete/delete_food_bloc.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/detail/detail_food_admin_bloc.dart';
import 'package:foodapin/features/admin/foods/bloc/foods_bloc.dart';
import 'package:foodapin/features/admin/transactions/bloc/all_transactions/transactions_bloc.dart';
import 'package:foodapin/features/admin/update_food/bloc/detail_update/detail_update_food_bloc.dart';
import 'package:foodapin/features/admin/update_food/bloc/update/update_food_state.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_cubit.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_state.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_bloc.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_bloc.dart';
import 'package:foodapin/features/user/detail_food/bloc/detail_food/detail_food_bloc.dart';
import 'package:foodapin/features/user/home/bloc/home_bloc.dart';
import 'package:foodapin/features/user/my_cart/cart_bloc/cart_bloc.dart';
import 'package:foodapin/features/user/my_cart/create_transaction_bloc/create_transaction_bloc.dart';
import 'package:foodapin/features/user/my_cart/payment_method_bloc/payment_method_bloc.dart';
import 'package:foodapin/features/user/my-favourite/bloc/my_fav_bloc.dart';
import 'package:foodapin/features/user/transaction_detail/bloc/transaction_detail_bloc.dart';
import 'package:foodapin/features/user/transaction/bloc/transaction_bloc.dart';

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CartRepository cartRepository;
  final FoodRepository foodRepository;
  final PaymentMethodRepository paymentMethodRepository;
  final RatingRepository ratingRepository;
  final TransactionRepository transactionRepository;
  final UserRepository userRepository;
  final UploadRepository uploadRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.cartRepository,
    required this.foodRepository,
    required this.paymentMethodRepository,
    required this.ratingRepository,
    required this.transactionRepository,
    required this.userRepository,
    required this.uploadRepository
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
          RepositoryProvider.value(value: uploadRepository)
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
            BlocProvider(
              create: (_) => DetailFoodBloc(
                foodRepository: foodRepository
              ),
            ),
            BlocProvider(
              create: (_) => CartBloc(
                cartRepository: cartRepository
              ),
            ),
            BlocProvider(
              create: (_) => PaymentMethodBloc(
                paymentMethodRepository: paymentMethodRepository
              ),
            ),
            BlocProvider(
              create: (_) => CreateTransactionBloc(
                transactionRepository: transactionRepository
              ),
            ),
            BlocProvider(
              create: (_) => TransactionBloc(
                transactionRepository: transactionRepository
              ),
            ),
            BlocProvider(
              create: (_) => TransactionDetailBloc(
                transactionRepository: transactionRepository,
                uploadRepository: uploadRepository
              ),
            ),
            BlocProvider<MyFavBloc>(
              create: (context) => MyFavBloc(foodRepository: foodRepository),
            ),
            BlocProvider<FoodsAdminBloc>(
              create: (context) => FoodsAdminBloc(foodRepository: foodRepository),
            ),
            BlocProvider<CreateFoodBloc>(
              create: (context) => CreateFoodBloc(foodRepository: foodRepository, uploadRepository: uploadRepository),
            ),
            BlocProvider<DetailFoodAdminBloc>(
              create: (context) => DetailFoodAdminBloc(foodRepository: foodRepository),
            ),
            BlocProvider<DeleteFoodBloc>(
              create: (context) => DeleteFoodBloc(foodRepository: foodRepository),
            ),
            BlocProvider<UpdateFoodBloc>(
              create: (context) => UpdateFoodBloc(foodRepository: foodRepository),
            ),
            BlocProvider<DetailUpdateFoodBloc>(
              create: (context) => DetailUpdateFoodBloc(foodRepository: foodRepository),
            ),
            BlocProvider<TransactionsBloc>(
              create: (context) => TransactionsBloc(transactionRepository: transactionRepository),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: '/signin',
            onGenerateRoute: (settings) {
            final authState = context.read<AuthCubit>().state;
            return AppRoutes(authState).onGenerateRoute(settings);
          },
          ),
        ),
      );
    },
  );
}

}