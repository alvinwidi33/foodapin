import 'package:foodapin/data/models/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<List<PaymentMethod>> getPaymentMethods();
  Future<PaymentMethod> generatePaymentMethods();

}
