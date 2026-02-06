import 'package:foodapin/data/models/transaction.dart';

abstract class TransactionRepository {
  Future<Transaction> getTransactionById(String id);
  Future<List<Transaction>> getMyTransactions();
  Future<List<Transaction>> getAllTransactions();
  Future<Transaction> createTransaction({
    required List<String> cartIds,
    required String paymentMethodId,
  });
  Future<void> cancelTransaction(String id);

  Future<Transaction> uploadProofPayment({
    required String transactionId,
    required String proofPaymentUrl,
  });

  Future<Transaction> updateTransactionStatus({
    required String transactionId,
    required String status,
  });
}
