import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/transaction.dart';

abstract class UpdateTransactionStatusState extends Equatable {
  const UpdateTransactionStatusState();

  @override
  List<Object?> get props => [];
}

class UpdateTransactionStatusInitial extends UpdateTransactionStatusState {}

class UpdateTransactionStatusLoading extends UpdateTransactionStatusState {}

class UpdateTransactionStatusSuccess extends UpdateTransactionStatusState {
  const UpdateTransactionStatusSuccess();

  @override
  List<Object?> get props => [];
}

class UpdateTransactionStatusFailure extends UpdateTransactionStatusState {
  final String message;

  const UpdateTransactionStatusFailure(this.message);

  @override
  List<Object?> get props => [message];
}