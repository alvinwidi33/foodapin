import 'package:dio/dio.dart';
import 'package:foodapin/data/models/cart.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Dio dio;

  CartRepositoryImpl(this.dio);

  @override
  Future<List<Cart>> getAllCarts() async {
    final res = await dio.get('/carts');
    final List list = res.data['data'];
    return list
      .map((e) => Cart.fromJson(e))
      .toList();
  }

  @override
  Future<void> addToCart(String foodId) async {
    await dio.post(
      '/add-cart',
      data: {
        'foodId': foodId,
      },
    );
  }

  @override
  Future<void> updateCartQuantity({
    required String id,
    required int quantity,
  }) async {
    await dio.put(
      '/update-cart/$id',
      data: {
        'quantity': quantity,
      },
    );
  }

  @override
  Future<void> deleteCart(String id) async {
    await dio.delete('/delete-cart/$id');
  }
}
