abstract class CartEvent {}

class FetchCarts extends CartEvent {}

class AddToCart extends CartEvent {
  final String foodId;
  final int quantity;

  AddToCart({
    required this.foodId,
    required this.quantity,
  });
}


class UpdateCartQuantity extends CartEvent {
  final String cartId;
  final int quantity;

  UpdateCartQuantity({
    required this.cartId,
    required this.quantity,
  });
}

class DeleteCart extends CartEvent {
  final String cartId;

  DeleteCart({required this.cartId});
}
