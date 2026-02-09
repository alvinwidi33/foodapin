import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
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
  Future<ApiResponse<Users>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final token = response.data['access_token'];
      await tokenStorage.save(token);

      return ApiResponse.success(
        Users.fromJson(response.data['data']),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
        final data = e.response?.data;

        String message = 'Failed registering user';

        if (data is Map && data['errors'] is List && data['errors'].isNotEmpty) {
          message = data['errors'][0]['message'] ?? message;
        }

        return ApiResponse.error(
          message,
          statusCode: e.response?.statusCode,
        );
    } catch (_) {
      return ApiResponse.error('Something went wrong');
    }
  }

  @override
  Future<ApiResponse<Users>> signUp({
    required Users user,
  }) async {
    try {
      final response = await dio.post(
        '/register',
        data: user.toJson(includePassword: true),
      );
      return ApiResponse.success(
        Users.fromJson(response.data['data']),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      String message = 'Failed registering user';

      if (data is Map && data['errors'] is List && data['errors'].isNotEmpty) {
        message = data['errors'][0]['message'] ?? message;
      }

      return ApiResponse.error(
        message,
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return ApiResponse.error('Something went wrong');
    }
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
