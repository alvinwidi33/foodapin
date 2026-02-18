import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/payment_method_repository/payment_method_repository.dart';
import 'package:foodapin/features/user/my-cart/payment_method_bloc/payment_method_event.dart';
import 'package:foodapin/features/user/my-cart/payment_method_bloc/payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final PaymentMethodRepository paymentMethodRepository;

  PaymentMethodBloc({required this.paymentMethodRepository}) : super(PaymentMethodInitial()) {
    on<FetchPaymentMethod>(_onFetchPaymentMethod);
  }

  Future<void> _onFetchPaymentMethod(
    FetchPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());

    final response = await paymentMethodRepository.getPaymentMethods();

    if (response.success && response.data != null) {
      emit(PaymentMethodLoaded(response.data!));
    } else {
      emit(PaymentMethodError(response.message ?? 'Failed to fetch payment methods'));
    }
  }
}