import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/foods.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  final Dio dio;

  FoodRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<List<Foods>>> getAllFoods() async {
    try {
      final response = await dio.get('/foods');
      final List list = response.data['data'];
      final foods = list
        .map((e) => Foods.fromJson(e))
        .toList();

      return ApiResponse.success(
          foods,
          statusCode:  response.statusCode,
        );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch foods',
        statusCode: e.response?.statusCode,
      );
    } catch (e){
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  @override
  Future<ApiResponse<Foods>> getFoodById(String id) async {
    try {
      final response = await dio.get('/foods/$id');
      final food = Foods.fromJson(response.data['data']);
      return ApiResponse.success(
        food,
        statusCode: response.statusCode,
        );
  } on DioException catch (e) {
    return ApiResponse.error(
      e.response?.data['message'] ?? 'Failed to fetch food',
      statusCode: e.response?.statusCode,
    );
  } catch (e) {
    return ApiResponse.error('Unexpected error');
  }
}

  @override
  Future<ApiResponse<List<Foods>>> getUserLikedFoods() async {
    try {
      final response = await dio.get('/like-foods');
      final List list = response.data['data'];
      final foods = list
          .map((e) => Foods.fromJson(e))
          .toList();
      return ApiResponse.success(
        foods,
        statusCode:  response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch foods',
        statusCode: e.response?.statusCode,
      );
    } catch (e){
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<void>> createFood(Foods food) async {
    try {
      final res = await dio.post(
        '/create-food',
        data: food.toJson(),
      );

      return ApiResponse.success(
        null,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to create food',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<void>> updateFood(String id, Foods food) async {
    try {
      final response = await dio.post(
        '/update-food/$id',
        data: food.toJson(),
      );
      return ApiResponse.success(null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to update food',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<void>> deleteFood(String id) async {
    try {
      final response = await dio.delete('/delete-food/$id');
      return ApiResponse.success(null, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to delete food',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override 
  Future<ApiResponse<Foods>> likeFood(String foodId) async { 
    try {
      final response = await dio.post(
        '/like', 
        data: {'foodId': foodId}, 
      ); 
      final liked = Foods.fromJson(response.data['data']);
      return ApiResponse.success(liked, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to like food',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  } 
  @override 
  Future<ApiResponse<Foods>> unlikeFood(String foodId) async { 
    try {
      final response = await dio.post(
        '/unlike', 
        data: {'foodId': foodId}, 
      );
      final unliked = Foods.fromJson(response.data['data']);
     return ApiResponse.success(unliked, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to like food',
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }
}
