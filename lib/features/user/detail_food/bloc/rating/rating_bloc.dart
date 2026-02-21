import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/rating_repository/rating_repository.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepository ratingRepository;

  RatingBloc({required this.ratingRepository}) : super(RatingInitial()) {
    on<CreateRatingEvent>(_onCreateRating);
  }

  Future<void> _onCreateRating(
    CreateRatingEvent event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());

    final response = await ratingRepository.createRating(
      foodId: event.foodId,
      rating: event.rating,
      review: event.review,
    );

    if (response.success) {
      emit(RatingSuccess());
    } else {
      emit(RatingError(response.message ?? 'Failed to rate'));
    }
  }
}