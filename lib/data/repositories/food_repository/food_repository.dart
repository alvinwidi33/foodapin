import 'package:foodapin/data/models/foods.dart';

abstract class FoodRepository {
  Future<List<Foods>> getAllFoods();
  Future<List<Foods>> getUserLikedFoods();
  Future<Foods> getFoodById(String id);
  Future<Foods> createFood(Foods food);
  Future<Foods> updateFood(String id, Foods food);
  Future<void> deleteFood(String id);
  Future<void> likeFood(String id);
  Future<void> unlikeFood(String id);
}
