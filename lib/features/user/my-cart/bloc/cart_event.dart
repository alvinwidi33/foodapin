import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class FetchCart extends CartEvent {
  const FetchCart();
}

class UpdateCartQuantity extends CartEvent {
  final String cartId;
  final int quantity;

  const UpdateCartQuantity({
    required this.cartId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartId, quantity];
}

class DeleteCart extends CartEvent {
  final String cartId;

  const DeleteCart({required this.cartId});

  @override
  List<Object?> get props => [cartId];
}
