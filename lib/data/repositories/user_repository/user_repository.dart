import 'package:foodapin/data/models/users.dart';

abstract class UserRepository {
  Future<List<Users>> getAllUsers();
  Future<Users> getCurrentUser();
  Future<Users> updateProfile(Users user);
  Future<void> updateUserRole({
    required String userId,
    required String role,
  });
}
