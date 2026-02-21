import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/users.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<List<Users>>> getAllUsers() async {
    try {
      final res = await dio.get('/all-user');
      final List list = res.data['data'];

      final users = list
          .map((e) => Users.fromJson(e))
          .toList();

      return ApiResponse.success(
        users,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch users',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<Users>> getCurrentUser() async {
    try {
      final res = await dio.get('/user');

      return ApiResponse.success(
        Users.fromJson(res.data['user']),
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch user',
      );
    }
  }

  @override
  Future<ApiResponse<void>> updateProfile(Users user) async {
    try {
      final res = await dio.post(
        '/update-profile',
        data: {
          'name': user.name,
          'email': user.email,
          'phone_number': user.phoneNumber,
          'profile_picture_url': user.profilePictureUrl,
        },
      );

      return ApiResponse.success(
       null,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to update profile',
      );
    }
  }

  @override
  Future<ApiResponse<void>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await dio.post(
        '/update-user-role/$userId',
        data: {'role': role},
      );

      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to update role',
      );
    }
  }
}
