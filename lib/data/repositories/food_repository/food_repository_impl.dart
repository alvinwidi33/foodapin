import 'package:dio/dio.dart';
import 'package:foodapin/data/models/foods.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  final Dio dio;

  FoodRepositoryImpl(this.dio);

  @override
  Future<List<Foods>> getAllFoods() async {
    final res = await dio.get('/foods');
    final List list = res.data['data'];
    return list
      .map((e) => Foods.fromJson(e))
      .toList();
  }

  @override
  Future<Foods> getFoodById(String id) async {
    final res = await dio.get('/foods/$id');
    return Foods.fromJson(res.data['data']);
  }

  @override
  Future<List<Foods>> getUserLikedFoods() async {
    final res = await dio.get('/foods/liked');
    final List list = res.data['data'];
    return list
        .map((e) => Foods.fromJson(e))
        .toList();
  }

  @override
  Future<Foods> createFood(Foods food) async {
    final res = await dio.post(
      '/foods',
      data: food.toJson(),
    );
    return Foods.fromJson(res.data);
  }

  @override
  Future<Foods> updateFood(String id, Foods food) async {
    final res = await dio.post(
      '/foods/$id',
      data: food.toJson(),
    );
    return Foods.fromJson(res.data);
  }

  @override
  Future<void> deleteFood(String id) async {
    await dio.delete('/foods/$id');
  }

  @override 
  Future<void> likeFood(String foodId) async { 
    await dio.post(
      '/like', 
      data: {'foodId': foodId}, 
    ); 
  } 
  @override 
  Future<void> unlikeFood(String foodId) async { 
    await dio.post(
      '/unlike', 
      data: {'foodId': foodId}, 
    ); 
  }

}
