import 'package:dio/dio.dart';
import 'package:foodapin/data/models/users.dart';
import 'package:foodapin/data/network/token_storage.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio dio;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl({
    required this.dio,
    required this.tokenStorage,
  });

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final token = response.data['access_token'];
    await tokenStorage.save(token);
  }

  @override
  Future<void> signUp({
    required Users user,
  }) async {
    await dio.post(
      '/register',
      data: user.toJson(includePassword: true),
    );
  }


  @override
  Future<void> signOut() async {
    await tokenStorage.clear();
  }

  @override
  Future<bool> isLoggedIn() async {
    return tokenStorage.hasToken();
  }
}
