import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/transaction.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final Dio dio;

  TransactionRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<Transaction>> getTransactionById(String id) async {
    try {
      final res = await dio.get('/transaction/$id');
      final transaction = Transaction.fromJson(res.data['data']);

      return ApiResponse.success(
        transaction,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch transaction',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      print("ayam");
      return ApiResponse.error('Unexpected error transaction');
    }
  }

  @override
  Future<ApiResponse<List<Transaction>>> getMyTransactions() async {
    try {
      final res = await dio.get('/my-transactions');
      final List list = res.data['data'];

      final transactions = list
          .map((e) => Transaction.fromJson(e))
          .toList();

      return ApiResponse.success(
        transactions,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch transactions',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<List<Transaction>>> getAllTransactions() async {
    try {
      final res = await dio.get('/all-transactions');
      final List list = res.data['data'];

      final transactions = list
          .map((e) => Transaction.fromJson(e))
          .toList();

      return ApiResponse.success(
        transactions,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch transactions',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
Future<ApiResponse<void>> createTransaction({
  required List<String> cartIds,
  required String paymentMethodId,
}) async {
  try {
    final res = await dio.post(
      '/create-transaction',
      data: {
        'cartIds': cartIds,
        'paymentMethodId': paymentMethodId,
      },
    );

    return ApiResponse.success(
      null,
      statusCode: res.statusCode,
    );
  } on DioException catch (e) {
    return ApiResponse.error(
      e.response?.data['message'] ?? 'Failed to create transaction',
      statusCode: e.response?.statusCode,
    );
  } catch (_) {
    return ApiResponse.error('Unexpected error');
  }
}


  @override
  Future<ApiResponse<void>> cancelTransaction(String id) async {
    try {
      final res = await dio.post('/cancel-transaction/$id');

      return ApiResponse.success(
        null,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to cancel transaction',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<void>> uploadProofPayment({
    required String transactionId,
    required String proofPaymentUrl,
  }) async {
    try {
      final res = await dio.post(
        '/update-transaction-proof-payment/$transactionId',
        data: {
          'proofPaymentUrl': proofPaymentUrl,
        },
      );

      return ApiResponse.success(
        null,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to upload proof payment',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<void>> updateTransactionStatus({
    required String transactionId,
    required String status,
  }) async {
    try {
      final res = await dio.post(
        '/update-transaction-status/$transactionId',
        data: {'status': status},
      );

      return ApiResponse.success(
        null,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to update transaction status',
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return ApiResponse.error('Unexpected error');
    }
  }
}
