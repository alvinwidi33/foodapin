import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/features/user/my-cart/create_transaction/create_transaction_event.dart';
import 'package:foodapin/features/user/my-cart/create_transaction/create_transaction_state.dart';

class CreateTransactionBloc extends Bloc<CreateTransactionEvent, CreateTransactionState> {
  final TransactionRepository transactionRepository;

  CreateTransactionBloc({required this.transactionRepository})
      : super(CreateTransactionInitial()) {
    on<CreateTransaction>(_onCreateTransaction);
  }

  Future<void> _onCreateTransaction(
    CreateTransaction event,
    Emitter<CreateTransactionState> emit,
  ) async {
    emit(CreateTransactionLoading());

    final response = await transactionRepository.createTransaction(
      cartIds: event.cartIds,
      paymentMethodId: event.paymentMethodId,
    );

    if (response.success && response.data != null) {
      emit(CreateTransactionSuccess(response.data!));
    } else {
      emit(CreateTransactionError(response.message ?? 'Failed to create transaction'));
    }
  }
}
