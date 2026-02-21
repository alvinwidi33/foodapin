import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/rating.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingSuccess extends RatingState {}

class RatingError extends RatingState {
  final String message;

  const RatingError(this.message);

  @override
  List<Object?> get props => [message];
}
class RatingLoaded extends RatingState {
  final List<FoodRating> ratings;

  RatingLoaded(this.ratings);
}