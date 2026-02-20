import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/foods.dart';

abstract class FoodRepository {
  Future<ApiResponse<List<Foods>>> getAllFoods();
  Future<ApiResponse<List<Foods>>> getUserLikedFoods();
  Future<ApiResponse<Foods>> getFoodById(String id);
  Future<ApiResponse<void>> createFood(Foods food);
  Future<ApiResponse<void>> updateFood(String id, Foods food);
  Future<ApiResponse<void>> deleteFood(String id);
  Future<ApiResponse<Foods>> likeFood(String id);
  Future<ApiResponse<Foods>> unlikeFood(String id);
}
