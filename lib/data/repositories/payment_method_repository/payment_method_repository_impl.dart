import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/payment_method.dart';
import 'package:foodapin/data/repositories/payment_method_repository/payment_method_repository.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final Dio dio;

  PaymentMethodRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    try {
      final response = await dio.get('/payment-methods');
      final List list = response.data['data'];
      final payments = list
          .map((e) => PaymentMethod.fromJson(e))
          .toList();
      return ApiResponse.success(
            payments,
            statusCode:  response.statusCode,
          );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch payments',
        statusCode: e.response?.statusCode,
      );
    } catch (e){
      return ApiResponse.error('Unexpected error');
    }
  }
  @override
  Future<ApiResponse<PaymentMethod>> generatePaymentMethods() async {
    try {
      final res = await dio.post('/generate-payment-methods');
      final payment = PaymentMethod.fromJson(res.data['data']);
      return ApiResponse.success(
        payment,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to generate payment',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }
}