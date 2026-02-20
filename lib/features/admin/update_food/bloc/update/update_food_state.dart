import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/admin/update_food/bloc/update/update_food_bloc.dart';
import 'package:foodapin/features/admin/update_food/bloc/update/update_food_event.dart';

class UpdateFoodBloc extends Bloc<UpdateFoodEvent, UpdateFoodState> {
  final FoodRepository foodRepository;

  UpdateFoodBloc({required this.foodRepository}) : super(UpdateFoodInitial()) {
    on<SubmitUpdateFood>(_onSubmitUpdateFood);
  }

  Future<void> _onSubmitUpdateFood(
    SubmitUpdateFood event,
    Emitter<UpdateFoodState> emit,
  ) async {
    emit(UpdateFoodLoading());

    final response = await foodRepository.updateFood(
      event.id,
      event.food,
    );

    if (response.success) {
      emit(UpdateFoodSuccess());
    } else {
      emit(UpdateFoodFailure(response.message ?? 'Update failed'));
    }
  }
}