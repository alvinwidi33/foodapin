
import 'package:foodapin/data/models/foods.dart';

abstract class DetailUpdateFoodState {}

class DetailUpdateFoodInitial extends DetailUpdateFoodState {}

class DetailUpdateFoodLoading extends DetailUpdateFoodState {}

class DetailUpdateFoodLoaded extends DetailUpdateFoodState {
  final Foods food;
  DetailUpdateFoodLoaded(this.food);
}

class DetailUpdateFoodError extends DetailUpdateFoodState {
  final String message;
  DetailUpdateFoodError(this.message);
}