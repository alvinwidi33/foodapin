
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/detail/detail_food_admin_event.dart';
import 'package:foodapin/features/admin/detail_food_admin/bloc/detail/detail_food_admin_state.dart';

class DetailFoodAdminBloc extends Bloc<DetailFoodAdminEvent, DetailFoodAdminState> {
  final FoodRepository foodRepository;

  DetailFoodAdminBloc({ required this.foodRepository}) : super(DetailFoodAdminInitial()) {
    on<FetchFoodAdminDetail>(_fetchFoodDetail);
  }

  Future<void> _fetchFoodDetail(
    FetchFoodAdminDetail event,
    Emitter<DetailFoodAdminState> emit,
  ) async {
    emit(DetailFoodAdminLoading());

    try {
      final response = await foodRepository.getFoodById(event.foodId);

      if (!response.success || response.data == null) {
        emit(DetailFoodAdminError(response.message ?? 'Failed to load food'));
        return;
      }

      emit(DetailFoodAdminLoaded(response.data!));
    } catch (e) {
      emit(DetailFoodAdminError(e.toString()));
    }
  }
}