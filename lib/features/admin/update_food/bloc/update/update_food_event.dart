import 'package:equatable/equatable.dart';

abstract class UpdateFoodState extends Equatable {
  const UpdateFoodState();

  @override
  List<Object?> get props => [];
}

class UpdateFoodInitial extends UpdateFoodState {}

class UpdateFoodLoading extends UpdateFoodState {}

class UpdateFoodSuccess extends UpdateFoodState {}

class UpdateFoodFailure extends UpdateFoodState {
  final String message;

  const UpdateFoodFailure(this.message);

  @override
  List<Object?> get props => [message];
}