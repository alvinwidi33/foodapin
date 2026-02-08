import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/rating.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository.dart';

class RatingRepositoryImpl implements RatingRepository {
  final Dio dio;

  RatingRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<List<FoodRating>>> getRatingsByFood(String foodId) async {
    try {
      final res = await dio.get('/food-rating/$foodId');
      final List list = res.data['data'];

      final ratings = list
          .map((e) => FoodRating.fromJson(e))
          .toList();

      return ApiResponse.success(
        ratings,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to fetch ratings',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }

  @override
  Future<ApiResponse<FoodRating>> createRating({
    required String foodId,
    required int rating,
    required String review,
  }) async {
    try {
      final res = await dio.post(
        '/rate-food/$foodId',
        data: {
          'rating': rating,
          'review': review,
        },
      );

      final rate = FoodRating.fromJson(res.data['data']);
      return ApiResponse.success(
        rate,
        statusCode: res.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to rate',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('Unexpected error');
    }
  }
}
