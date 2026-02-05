import 'package:foodapin/data/models/rating.dart';

abstract class RatingRepository {
  Future<List<FoodRating>> getRatingsByFood(String foodId);

  Future<void> createRating({
    required String foodId,
    required int rating,
    required String review,
  });
}
