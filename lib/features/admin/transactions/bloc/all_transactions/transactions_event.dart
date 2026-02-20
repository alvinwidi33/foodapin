import 'package:equatable/equatable.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactions extends TransactionsEvent {
  const FetchTransactions();
}

class RefreshTransactions extends TransactionsEvent {
  const RefreshTransactions();
}