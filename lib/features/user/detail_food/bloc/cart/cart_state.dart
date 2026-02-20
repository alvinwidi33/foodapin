import 'package:foodapin/data/models/cart.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<Cart> carts;

  CartLoaded(this.carts);
}

class CartSuccess extends CartState {
  final String message;

  CartSuccess(this.message);
}

class CartFailure extends CartState {
  final String message;

  CartFailure(this.message);
}
