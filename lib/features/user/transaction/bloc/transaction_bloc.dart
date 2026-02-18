import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/features/user/transaction/bloc/transaction_event.dart';
import 'package:foodapin/features/user/transaction/bloc/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository transactionRepository;

  TransactionBloc({required this.transactionRepository}) : super(TransactionInitial()) {
    on<FetchTransaction>(_onFetchTransaction);
  }

  Future<void> _onFetchTransaction(
    FetchTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    final response = await transactionRepository.getMyTransactions();

    if (response.success && response.data != null) {
      emit(TransactionLoaded(response.data!));
    } else {
      emit(TransactionError(response.message ?? 'Failed to fetch payment methods'));
    }
  }
}