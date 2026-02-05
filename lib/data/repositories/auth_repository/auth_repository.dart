import 'package:foodapin/data/models/users.dart';

abstract class AuthRepository {
  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required Users user,
  });

  Future<void> signOut();

  Future<bool> isLoggedIn();
}
