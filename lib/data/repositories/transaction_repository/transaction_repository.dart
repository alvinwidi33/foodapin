import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/transaction.dart';

abstract class TransactionRepository {
  Future<ApiResponse<Transaction>> getTransactionById(String id);
  Future<ApiResponse<List<Transaction>>> getMyTransactions();
  Future<ApiResponse<List<Transaction>>> getAllTransactions();
  Future<ApiResponse<Transaction>> createTransaction({
    required List<String> cartIds,
    required String paymentMethodId,
  });
  Future<ApiResponse<void>> cancelTransaction(String id);

  Future<ApiResponse<Transaction>> uploadProofPayment({
    required String transactionId,
    required String proofPaymentUrl,
  });

  Future<ApiResponse<Transaction>> updateTransactionStatus({
    required String transactionId,
    required String status,
  });
}
