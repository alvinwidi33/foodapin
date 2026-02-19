import 'package:equatable/equatable.dart';

abstract class TransactionDetailEvent extends Equatable {
  const TransactionDetailEvent();

  @override
  List<Object?> get props => [];
}

class GetTransactionDetail extends TransactionDetailEvent {
  final String transactionId;

  const GetTransactionDetail(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class CancelTransactionEvent extends TransactionDetailEvent {
  final String transactionId;

  const CancelTransactionEvent(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

class UploadProofPaymentEvent extends TransactionDetailEvent {
  final String transactionId;
  final String proofPaymentUrl;

  const UploadProofPaymentEvent({
    required this.transactionId,
    required this.proofPaymentUrl,
  });

  @override
  List<Object?> get props => [transactionId, proofPaymentUrl];
}
