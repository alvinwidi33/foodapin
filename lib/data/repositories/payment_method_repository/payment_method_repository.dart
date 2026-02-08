import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods();
  Future<ApiResponse<PaymentMethod>> generatePaymentMethods();

}
