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

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? [];
          
      final carts = data.map((json) {
        return Cart.fromJson(json);
      }).toList();

      return ApiResponse.success(
        carts,
        statusCode: response.statusCode,
      );
    } else {
      return ApiResponse.error(
        response.data['message'] ?? 'Failed to fetch carts',
        statusCode: response.statusCode,
      );
    }
  } on DioException catch (e) {
    return ApiResponse.error(
      e.response?.data['message'] ?? 'Failed to fetch carts',
      statusCode: e.response?.statusCode,
    );
  } catch (e) {
    return ApiResponse.error('Unexpected error: $e');
  }
}

@override
Future<ApiResponse<Cart?>> addToCart(String foodId) async {
  try {
    
    final response = await dio.post(
      '/add-cart',
      data: {
        'foodId': foodId,
      },
    );
    return ApiResponse.success(
      null, 
      statusCode: response.statusCode,
    );
    
  } on DioException catch (e) {
    return ApiResponse.error(
      e.response?.data['message'] ?? 'Failed to post cart',
    );
  } catch (e) {
    return ApiResponse.error('Unexpected error: $e');
  }
}

@override
Future<ApiResponse<Cart?>> updateCartQuantity({
  required String id,
  required int quantity,
}) async {
  try {
    final response = await dio.post(
      '/update-cart/$id',
      data: {'quantity': quantity},
    );

    if (response.statusCode == 200) {
      if (response.data is Map && response.data['data'] != null) {
        final cart = Cart.fromJson(response.data['data']);
        return ApiResponse.success(cart, statusCode: response.statusCode);
      } else {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }
    } else {
      return ApiResponse.error('Update failed (${response.statusCode})');
    }
    
  } on DioException catch (e) {
    
    String errorMessage = 'Failed to update cart';
    
    if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is String) {
        if (responseData.contains('Cannot PUT')) {
          errorMessage = 'Cart not found or already deleted';
        } else if (responseData.contains('<!DOCTYPE html>')) {
          errorMessage = 'Server error (${e.response!.statusCode})';
        } else {
          errorMessage = responseData;
        }
      } else if (responseData is Map) {
        // JSON response
        final msg = responseData['message'];
        errorMessage = msg?.toString() ?? errorMessage;
      }
    } else {
      errorMessage = e.message ?? 'Network error';
    }
  
    return ApiResponse.error(errorMessage);
    
  } catch (e) {
    return ApiResponse.error('Unexpected error: $e');
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
      return ApiResponse.error('Unexpected error: $e');
    }
  }
}