import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/cart.dart';

abstract class CartRepository {
  Future<ApiResponse<List<Cart>>> getAllCarts();
  Future<ApiResponse<Cart>> addToCart(String foodId);
  Future<ApiResponse<Cart>> updateCartQuantity({required String id, required int quantity});
  Future<ApiResponse<void>> deleteCart(String id);
}
