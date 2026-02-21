import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/users.dart';

abstract class UserRepository {
  Future<ApiResponse<List<Users>>> getAllUsers();
  Future<ApiResponse<Users>> getCurrentUser();
  Future<ApiResponse<void>> updateProfile(Users user);
  Future<ApiResponse<void>> updateUserRole({
    required String userId,
    required String role,
  });
}
