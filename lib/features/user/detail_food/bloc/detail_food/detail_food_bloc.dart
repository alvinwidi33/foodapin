
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/user/detail_food/bloc/detail_food/detail_food_event.dart';
import 'package:foodapin/features/user/detail_food/bloc/detail_food/detail_food_state.dart';

class DetailFoodBloc extends Bloc<DetailFoodEvent, DetailFoodState> {
  final FoodRepository foodRepository;

  DetailFoodBloc({ required this.foodRepository}) : super(DetailFoodInitial()) {
    on<FetchFoodDetail>(_fetchFoodDetail);
  }

  Future<void> _fetchFoodDetail(
    FetchFoodDetail event,
    Emitter<DetailFoodState> emit,
  ) async {
    emit(DetailFoodLoading());

    try {
      final response = await foodRepository.getFoodById(event.foodId);

      if (!response.success || response.data == null) {
        emit(DetailFoodError(response.message ?? 'Failed to load food'));
        return;
      }

      emit(DetailFoodLoaded(response.data!));
    } catch (e) {
      emit(DetailFoodError(e.toString()));
    }
  }
}