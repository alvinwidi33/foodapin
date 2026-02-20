import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';
import 'package:foodapin/features/user/my_cart/cart_bloc/cart_event.dart';
import 'package:foodapin/features/user/my_cart/cart_bloc/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<UpdateCartQuantity>(_onUpdate);
    on<DeleteCart>(_onDelete);
  }

  Future<void> _onFetchCart(
    FetchCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final response = await cartRepository.getAllCarts();

    if (response.success && response.data != null) {
      emit(CartLoaded(response.data!));
    } else {
      emit(CartError(response.message ?? 'Failed to fetch carts'));
    }
  }

  Future<void> _onUpdate(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    if (event.quantity <= 0) {
      add(DeleteCart(cartId: event.cartId));
      return;
    }

    emit(CartLoading());

    final response = await cartRepository.updateCartQuantity(
      id: event.cartId,
      quantity: event.quantity,
    );

    if (response.success) {
      add(const FetchCart());
    } else {
      emit(CartError(response.message ?? 'Failed to update cart'));
    }
  }

  Future<void> _onDelete(
    DeleteCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final response = await cartRepository.deleteCart(event.cartId);

    if (response.success) {
      add(const FetchCart());
    } else {
      emit(CartError(response.message ?? 'Failed to delete cart'));
    }
  }
}
