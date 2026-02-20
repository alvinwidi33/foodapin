abstract class DetailUpdateFoodEvent {}

class FetchFoodUpdateDetail extends DetailUpdateFoodEvent {
  final String foodId;
  FetchFoodUpdateDetail({required this.foodId});
}