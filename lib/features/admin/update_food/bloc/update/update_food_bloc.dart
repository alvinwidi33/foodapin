import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/foods.dart';

abstract class UpdateFoodEvent extends Equatable {
  const UpdateFoodEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUpdateFood extends UpdateFoodEvent {
  final String id;
  final Foods food;

  const SubmitUpdateFood({
    required this.id,
    required this.food,
  });

  @override
  List<Object?> get props => [id, food];
}