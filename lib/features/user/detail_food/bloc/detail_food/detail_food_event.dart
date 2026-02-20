abstract class DetailFoodEvent {}

class FetchFoodDetail extends DetailFoodEvent {
  final String foodId;
  FetchFoodDetail({required this.foodId});
}