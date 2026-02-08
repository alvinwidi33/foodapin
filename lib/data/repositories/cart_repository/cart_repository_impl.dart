import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/cart.dart';
import 'package:foodapin/data/repositories/cart_repository/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Dio dio;

  CartRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<List<Cart>>> getAllCarts() async {
    try {
      final response = await dio.get('/carts');
      final List list = response.data['data'];

      final carts = list
        .map((e) => Cart.fromJson(e))
        .toList();

      return ApiResponse.success(
        carts,
        statusCode:  response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch carts',
        statusCode: e.response?.statusCode,
      );
    } catch (e){
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<Cart>> addToCart(String foodId) async {
    try {
      final response = await dio.post(
        '/add-cart',
        data: {
          'foodId': foodId,
        },
      );
      final cart = Cart.fromJson(response.data['data']);
      return ApiResponse.success(cart, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to post cart',
      );
    }
  }

  @override
  Future<ApiResponse<Cart>> updateCartQuantity({
    required String id,
    required int quantity,
  }) async {
    try {
      final response = await dio.put(
        '/update-cart/$id',
        data: {
          'quantity': quantity,
        },
      );
      final cart = Cart.fromJson(response.data['data']);
      return ApiResponse.success(cart, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to update cart',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<void>> deleteCart(String id) async {
    try {
      final response = await dio.delete('/delete-cart/$id');
      return ApiResponse.success(null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to delete cart',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }
}
