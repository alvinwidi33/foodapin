import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:foodapin/data/network/auth_interceptor.dart';
import 'package:foodapin/data/network/token_storage.dart';

class DioApiClient {
  static final DioApiClient _instance = DioApiClient._internal();
  factory DioApiClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;

  DioApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['BASE_URL']!,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'apiKey': dotenv.env['API_KEY']!,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
        validateStatus: (status) {
          return status != null && status >= 200 && status < 400;
        },
      ),
    );
    _dio.interceptors.add(AuthInterceptor(TokenStorage()));
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }
}
