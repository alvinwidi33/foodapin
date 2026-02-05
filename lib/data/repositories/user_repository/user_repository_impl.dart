import 'package:dio/dio.dart';
import 'package:foodapin/data/models/users.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final Dio dio;

  UserRepositoryImpl(this.dio);

  @override
  Future<List<Users>> getAllUsers() async {
    final res = await dio.get('/all-user');
    final List list = res.data['data'];
    return list
        .map((e) => Users.fromJson(e))
        .toList();
  }

  @override
  Future<Users> getCurrentUser() async {
    final res = await dio.get('/user');
    return Users.fromJson(res.data['user']);
  }

  @override
  Future<Users> updateProfile(Users user) async {
    final res = await dio.put(
      '/update-profile',
      data: {
        'name': user.name,
        'email': user.email,
        'phone_number': user.phoneNumber,
        'profile_picture_url': user.profilePictureUrl,
      },
    );

    return Users.fromJson(res.data);
  }

  @override
  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    await dio.patch(
      '/update-user-role/$userId',
      data: {'role': role},
    );
  }
}
