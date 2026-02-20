
import 'package:foodapin/data/models/foods.dart';

abstract class DetailFoodAdminState {}

class DetailFoodAdminInitial extends DetailFoodAdminState {}

class DetailFoodAdminLoading extends DetailFoodAdminState {}

class DetailFoodAdminLoaded extends DetailFoodAdminState {
  final Foods food;
  DetailFoodAdminLoaded(this.food);
}

class DetailFoodAdminError extends DetailFoodAdminState {
  final String message;
  DetailFoodAdminError(this.message);
}