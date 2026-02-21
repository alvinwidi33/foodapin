import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/rating.dart';

abstract class RatingRepository {
  Future<ApiResponse<List<FoodRating>>> getRatingsByFood(String foodId);

  Future<ApiResponse<void>> createRating({
    required String foodId,
    required int rating,
    required String review,
  });
}
