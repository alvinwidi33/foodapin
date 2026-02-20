import 'package:equatable/equatable.dart';

abstract class UpdateTransactionStatusEvent extends Equatable {
  const UpdateTransactionStatusEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUpdateTransactionStatus extends UpdateTransactionStatusEvent {
  final String transactionId;
  final String status;

  const SubmitUpdateTransactionStatus({
    required this.transactionId,
    required this.status,
  });

  @override
  List<Object?> get props => [transactionId, status];
}