abstract class DetailFoodAdminEvent {}

class FetchFoodAdminDetail extends DetailFoodAdminEvent {
  final String foodId;
  FetchFoodAdminDetail({required this.foodId});
}