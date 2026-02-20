import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';
import 'package:foodapin/features/user/detail_food/bloc/cart/cart_event.dart';
import 'package:foodapin/features/user/detail_food/bloc/cart/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc({required this.cartRepository}) : super(CartInitial()) {
    on<FetchCarts>(_onFetch);
    on<AddToCart>(_onAdd);
    on<UpdateCartQuantity>(_onUpdate);
    on<DeleteCart>(_onDelete);
  }

  Future<void> _onFetch(
    FetchCarts event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final response = await cartRepository.getAllCarts();

    if (response.success) {
      emit(CartLoaded(response.data!));
    } else {
      emit(CartFailure(response.message ?? 'Failed'));
    }
  }

Future<void> _onAdd(
  AddToCart event,
  Emitter<CartState> emit,
) async {
  try {
    emit(CartLoading());

    final addResponse = await cartRepository.addToCart(event.foodId);
    if (!addResponse.success) {
      emit(CartFailure(addResponse.message ?? "Failed"));
      return;
    }

    if (event.quantity == 1) {
      emit(CartSuccess("Added to cart"));
      return;
    }

    await Future.delayed(const Duration(milliseconds: 800));
    final fetchResponse = await cartRepository.getAllCarts();

    if (!fetchResponse.success || fetchResponse.data == null) {
      emit(CartFailure("Cannot fetch carts"));
      return;
    }

    // Step 3: Find matching cart
    final matchingCarts = fetchResponse.data!
        .where((cart) => cart.foodId == event.foodId)
        .toList();

    if (matchingCarts.isEmpty) {
      emit(CartFailure("Cart not found"));
      return;
    }

    matchingCarts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final targetCart = matchingCarts.first;

    await cartRepository.updateCartQuantity(
      id: targetCart.id,
      quantity: event.quantity,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    final verifyResponse = await cartRepository.getAllCarts();

    if (verifyResponse.success && verifyResponse.data != null) {
      final updatedCart = verifyResponse.data!.firstWhere(
        (c) => c.id == targetCart.id,
        orElse: () => targetCart,
      );

      if (updatedCart.quantity == event.quantity) {
        emit(CartSuccess("Added ${event.quantity}x to cart"));
        return;
      }
    }

    emit(CartFailure("Failed to verify update"));

  } catch (e) {
    emit(CartFailure("Error: $e"));
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
      emit(CartSuccess("Cart updated"));
      add(FetchCarts());
    } else {
      emit(CartFailure(response.message ?? 'Failed'));
    }
  }

  Future<void> _onDelete(
    DeleteCart event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    final response = await cartRepository.deleteCart(event.cartId);

    if (response.success) {
      emit(CartSuccess("Item removed"));
      add(FetchCarts());
    } else {
      emit(CartFailure(response.message ?? 'Failed'));
    }
  }
}