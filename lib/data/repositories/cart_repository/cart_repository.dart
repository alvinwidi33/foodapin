import 'package:foodapin/data/models/cart.dart';

abstract class CartRepository {
  Future<List<Cart>> getAllCarts();
  Future<void> addToCart(String foodId);
  Future<void> updateCartQuantity({required String id, required int quantity});
  Future<void> deleteCart(String id);
}
