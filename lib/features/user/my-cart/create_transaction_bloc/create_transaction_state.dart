import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/transaction.dart';

abstract class CreateTransactionState extends Equatable {
  const CreateTransactionState();

  @override
  List<Object?> get props => [];
}

class CreateTransactionInitial extends CreateTransactionState {}

class CreateTransactionLoading extends CreateTransactionState {}

class CreateTransactionSuccess extends CreateTransactionState {
  final Transaction transaction;

  const CreateTransactionSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class CreateTransactionError extends CreateTransactionState {
  final String message;

  const CreateTransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
