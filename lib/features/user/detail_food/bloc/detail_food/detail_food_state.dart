
import 'package:foodapin/data/models/foods.dart';

abstract class DetailFoodState {}

class DetailFoodInitial extends DetailFoodState {}

class DetailFoodLoading extends DetailFoodState {}

class DetailFoodLoaded extends DetailFoodState {
  final Foods food;
  DetailFoodLoaded(this.food);
}

class DetailFoodError extends DetailFoodState {
  final String message;
  DetailFoodError(this.message);
}