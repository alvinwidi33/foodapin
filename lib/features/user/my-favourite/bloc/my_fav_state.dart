import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/foods.dart';

abstract class MyFavState extends Equatable {
  const MyFavState();

  @override
  List<Object?> get props => [];
}

class MyFavInitial extends MyFavState {}

class MyFavLoading extends MyFavState {}

class MyFavLoaded extends MyFavState {
  final List<Foods> foods;

  const MyFavLoaded(this.foods);

  @override
  List<Object?> get props => [foods];
}

class MyFavError extends MyFavState {
  final String message;

  const MyFavError(this.message);

  @override
  List<Object?> get props => [message];
}