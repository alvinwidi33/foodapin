import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:foodapin/app.dart';
import 'package:foodapin/data/network/dio_api_client.dart';
import 'package:foodapin/data/network/token_storage.dart';

import 'package:foodapin/data/repositories/auth_repository/auth_repository_impl.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository_impl.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository_impl.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository_impl.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository_impl.dart';
import 'package:foodapin/data/repositories/payment_method_repository/payment_method_repository_impl.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository_impl.dart';
import 'package:foodapin/features/authentication/auth_cubit/auth_cubit.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final dioClient = DioApiClient();
  final tokenStorage = TokenStorage();

  final authRepository = AuthRepositoryImpl(
    dio: dioClient.dio,
    tokenStorage: tokenStorage,
  );
  final userRepository = UserRepositoryImpl(dioClient.dio);
  runApp(
    BlocProvider(
      create: (_) => AuthCubit(authRepository, userRepository)..checkAuth(),
      child: MyApp(
        authRepository: authRepository,
        userRepository: UserRepositoryImpl(dioClient.dio),
        foodRepository: FoodRepositoryImpl(dioClient.dio),
        cartRepository: CartRepositoryImpl(dioClient.dio),
        ratingRepository: RatingRepositoryImpl(dioClient.dio),
        paymentMethodRepository:
            PaymentMethodRepositoryImpl(dioClient.dio),
        transactionRepository:
            TransactionRepositoryImpl(dioClient.dio),
      ),
    ),
  );
}
