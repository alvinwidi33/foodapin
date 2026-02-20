import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/features/admin/transactions/bloc/all_transactions/transactions_event.dart';
import 'package:foodapin/features/admin/transactions/bloc/all_transactions/transactions_state.dart';


class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;

  TransactionsBloc({required this.transactionRepository}) : super(TransactionsInitial()) {
    on<FetchTransactions>(_onFetchTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
  }

  Future<void> _onFetchTransactions(
    FetchTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(TransactionsLoading());

    final response = await transactionRepository.getAllTransactions();

    if (response.success) {
      emit(TransactionsLoaded(response.data ?? []));
    } else {
      emit(TransactionsError(response.message ?? 'Failed to fetch transactions'));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionsState> emit,
  ) async {
    final response = await transactionRepository.getAllTransactions();

    if (response.success) {
      emit(TransactionsLoaded(response.data ?? []));
    } else {
      emit(TransactionsError(response.message ?? 'Failed to refresh transactions'));
    }
  }
}