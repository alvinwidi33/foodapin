import 'package:equatable/equatable.dart';

abstract class CreateTransactionState extends Equatable {
  const CreateTransactionState();

  @override
  List<Object?> get props => [];
}

class CreateTransactionInitial extends CreateTransactionState {}

class CreateTransactionLoading extends CreateTransactionState {}

class CreateTransactionSuccess extends CreateTransactionState {}

class CreateTransactionError extends CreateTransactionState {
  final String message;

  const CreateTransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
