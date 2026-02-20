import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'delete_food_event.dart';
import 'delete_food_state.dart';

class DeleteFoodBloc extends Bloc<DeleteFoodEvent, DeleteFoodState> {
  final FoodRepository foodRepository;

  DeleteFoodBloc({required this.foodRepository})
      : super(const DeleteFoodState()) {

    on<DeleteFoodRequested>((event, emit) async {
      emit(state.copyWith(
        isLoading: true,
        success: false,
        errorMessage: null,
      ));

      final result = await foodRepository.deleteFood(event.id);

      if (result.success) {
        emit(state.copyWith(
          isLoading: false,
          success: true,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.message,
        ));
      }
    });
  }
}