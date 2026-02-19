import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/transaction_repository/transaction_repository.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'transaction_detail_event.dart';
import 'transaction_detail_state.dart';

class TransactionDetailBloc
    extends Bloc<TransactionDetailEvent, TransactionDetailState> {
  final TransactionRepository transactionRepository;
  final UploadRepository uploadRepository;

  TransactionDetailBloc({required this.transactionRepository, required this.uploadRepository,})
      : super(const TransactionDetailState()) {

    on<GetTransactionDetail>(_onGetDetail);
    on<CancelTransactionEvent>(_onCancelTransaction);
    on<UploadProofPaymentEvent>(_onUploadProof);
  }

  Future<void> _onGetDetail(
    GetTransactionDetail event,
    Emitter<TransactionDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final response = await transactionRepository.getTransactionById(event.transactionId);

    if (response.success) {
      emit(state.copyWith(
        isLoading: false,
        transaction: response.data,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      ));
    }
  }

  Future<void> _onCancelTransaction(
    CancelTransactionEvent event,
    Emitter<TransactionDetailState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    final response = await transactionRepository.cancelTransaction(event.transactionId);

    if (response.success) {
      emit(state.copyWith(
        isSubmitting: false,
        successMessage: "Transaction cancelled successfully",
      ));
    } else {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: response.message,
      ));
    }
  }

  Future<void> _onUploadProof(
  UploadProofPaymentEvent event,
  Emitter<TransactionDetailState> emit,
) async {
  emit(state.copyWith(isSubmitting: true, errorMessage: null));

  final response = await transactionRepository.uploadProofPayment(
    transactionId: event.transactionId,
    proofPaymentUrl: event.proofPaymentUrl,
  );

  if (response.success) {
    final detailResponse =
        await transactionRepository.getTransactionById(
      event.transactionId,
    );

    emit(state.copyWith(
      isSubmitting: false,
      transaction: detailResponse.data,
      successMessage: response.message,
    ));
  } else {
    emit(state.copyWith(
      isSubmitting: false,
      errorMessage: response.message,
    ));
  }
}
}
