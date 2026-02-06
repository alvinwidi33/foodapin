import 'package:dio/dio.dart';
import 'package:foodapin/data/models/transaction.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final Dio dio;

  TransactionRepositoryImpl(this.dio);

  @override
  Future<Transaction> getTransactionById(String id) async {
    final res = await dio.get(
      '/transaction/$id',
    );

    return Transaction.fromJson(res.data['data']);
  }

  @override
  Future<List<Transaction>> getMyTransactions() async {
    final res = await dio.get(
      '/my-transactions',
    );
    final List list = res.data['data'];
    return list
        .map((e) => Transaction.fromJson(e))
        .toList();
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final res = await dio.get(
      '/all-transactions',
    );
    final List list = res.data['data'];
    return list
        .map((e) => Transaction.fromJson(e))
        .toList();
  }

  @override
  Future<Transaction> createTransaction({
    required List<String> cartIds,
    required String paymentMethodId,
  }) async {
    final res = await dio.post(
      '/create-transaction',
      data: {
        'cart_ids': cartIds,
        'payment_method_id': paymentMethodId,
      },
    );

    return Transaction.fromJson(res.data['data']);
  }

  @override
  Future<void> cancelTransaction(String id) async {
    await dio.post(
      '/cancel-transactions/$id',
    );
  }

  @override
  Future<Transaction> uploadProofPayment({
    required String transactionId,
    required String proofPaymentUrl,
  }) async {
    final response = await dio.post(
      '/update-transaction-proof-payment/$transactionId',
      data: {
        'proof_payment_url': proofPaymentUrl,
      },
    );

    return Transaction.fromJson(response.data['data']);
  }

  @override
  Future<Transaction> updateTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    final response = await dio.patch(
      '/update-transaction-status/$transactionId',
      data: {
        'status': status,
      },
    );

    return Transaction.fromJson(response.data['data']);
  }
}
