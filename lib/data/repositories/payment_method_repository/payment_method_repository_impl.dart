import 'package:dio/dio.dart';
import 'package:foodapin/data/models/payment_method.dart';
import 'package:foodapin/data/repositories/payment_method_repository/payment_method_repository.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final Dio dio;

  PaymentMethodRepositoryImpl(this.dio);

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final res = await dio.get('/payment-methods');
    final List list = res.data['data'];
    return list
        .map((e) => PaymentMethod.fromJson(e))
        .toList();
  }
  @override
  Future<PaymentMethod> generatePaymentMethods() async {
    final res = await dio.post('/generate-payment-methods');

    return PaymentMethod.fromJson(res.data['data']);
  }
}
