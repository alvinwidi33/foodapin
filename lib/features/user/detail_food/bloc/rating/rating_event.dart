import 'package:equatable/equatable.dart';

abstract class RatingEvent extends Equatable {
  const RatingEvent();

  @override
  List<Object?> get props => [];
}

class CreateRatingEvent extends RatingEvent {
  final String foodId;
  final int rating;
  final String review;

  const CreateRatingEvent({
    required this.foodId,
    required this.rating,
    required this.review,
  });

  @override
  List<Object?> get props => [foodId, rating, review];
}