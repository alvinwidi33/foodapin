import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'access_token';
  final _storage = const FlutterSecureStorage();

  Future<void> save(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<bool> hasToken() async {
    return await _storage.read(key: _key) != null;
  }

  Future<String?> get() async {
    return await _storage.read(key: _key);
  }

  Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}
