import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/users.dart';

abstract class AuthRepository {
  Future<ApiResponse<Users>> signIn({
    required String email,
    required String password,
  });

  Future<ApiResponse<Users>> signUp({
    required Users user,
  });

  Future<void> signOut();

  Future<bool> isLoggedIn();
}
