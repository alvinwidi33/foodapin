import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/features/admin/transactions/bloc/update_status/update_status_event.dart';
import 'package:foodapin/features/admin/transactions/bloc/update_status/update_status_state.dart';

class UpdateTransactionStatusBloc
    extends Bloc<UpdateTransactionStatusEvent, UpdateTransactionStatusState> {
  final TransactionRepository transactionRepository;

  UpdateTransactionStatusBloc({
    required this.transactionRepository,
  }) : super(UpdateTransactionStatusInitial()) {
    on<SubmitUpdateTransactionStatus>(_onSubmitUpdateTransactionStatus);
  }

  Future<void> _onSubmitUpdateTransactionStatus(
    SubmitUpdateTransactionStatus event,
    Emitter<UpdateTransactionStatusState> emit,
  ) async {
    emit(UpdateTransactionStatusLoading());

    final response = await transactionRepository.updateTransactionStatus(
      transactionId: event.transactionId,
      status: event.status,
    );

    if (response.success) {
      emit(UpdateTransactionStatusSuccess());
    } else {
      emit(
        UpdateTransactionStatusFailure(
          response.message ?? 'Failed to update status',
        ),
      );
    }
  }
}