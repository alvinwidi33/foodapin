
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/admin/update_food/bloc/detail_update/detail_update_food_event.dart';
import 'package:foodapin/features/admin/update_food/bloc/detail_update/detail_update_food_state.dart';

class DetailUpdateFoodBloc extends Bloc<DetailUpdateFoodEvent, DetailUpdateFoodState> {
  final FoodRepository foodRepository;

  DetailUpdateFoodBloc({ required this.foodRepository}) : super(DetailUpdateFoodInitial()) {
    on<FetchFoodUpdateDetail>(_fetchFoodDetail);
  }

  Future<void> _fetchFoodDetail(
    FetchFoodUpdateDetail event,
    Emitter<DetailUpdateFoodState> emit,
  ) async {
    emit(DetailUpdateFoodLoading());

    try {
      final response = await foodRepository.getFoodById(event.foodId);

      if (!response.success || response.data == null) {
        emit(DetailUpdateFoodError(response.message ?? 'Failed to load food'));
        return;
      }

      emit(DetailUpdateFoodLoaded(response.data!));
    } catch (e) {
      emit(DetailUpdateFoodError(e.toString()));
    }
  }
}