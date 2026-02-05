import 'package:dio/dio.dart';
import 'package:foodapin/data/models/rating.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final Dio dio;

  RatingRepositoryImpl(this.dio);

  @override
  Future<List<FoodRating>> getRatingsByFood(String foodId) async {
    final res = await dio.get('/food-rating/$foodId');

    final List list = res.data['data'];

    return list
        .map((e) => FoodRating.fromJson(e))
        .toList();
  }

  @override
  Future<void> createRating({
    required String foodId,
    required int rating,
    required String review,
  }) async {
    await dio.post(
      '/rate-food/$foodId',
      data: {
        'rating': rating,
        'review': review,
      },
    );
  }
}
