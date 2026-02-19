import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/transaction.dart';

class TransactionDetailState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final Transaction? transaction;
  final String? errorMessage;
  final String? successMessage;

  const TransactionDetailState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.transaction,
    this.errorMessage,
    this.successMessage,
  });

  TransactionDetailState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    Transaction? transaction,
    String? errorMessage,
    String? successMessage,
  }) {
    return TransactionDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      transaction: transaction ?? this.transaction,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isSubmitting, transaction, errorMessage, successMessage];
}
