import 'package:equatable/equatable.dart';

abstract class CreateTransactionEvent extends Equatable {
  const CreateTransactionEvent();

  @override
  List<Object?> get props => [];
}

class CreateTransaction extends CreateTransactionEvent {
  final List<String> cartIds;
  final String paymentMethodId;

  const CreateTransaction({
    required this.cartIds,
    required this.paymentMethodId,
  });

  @override
  List<Object?> get props => [cartIds, paymentMethodId];
}
