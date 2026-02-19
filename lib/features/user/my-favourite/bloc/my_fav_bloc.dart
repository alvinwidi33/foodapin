import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/user/my-favourite/bloc/my_fav_event.dart';
import 'package:foodapin/features/user/my-favourite/bloc/my_fav_state.dart';

class MyFavBloc extends Bloc<MyFavEvent, MyFavState> {
  final FoodRepository foodRepository;

  MyFavBloc({required this.foodRepository}) : super(MyFavInitial()) {
    on<FetchFavFoods>(_onFetchMyFav);
    on<ToggleLikeFoodFav>(_onToggleLikeFoodFav);
  }

  Future<void> _onFetchMyFav(
    FetchFavFoods event,
    Emitter<MyFavState> emit,
  ) async {
    emit(MyFavLoading());

    final response = await foodRepository.getUserLikedFoods();

    if (response.success && response.data != null) {
      emit(MyFavLoaded(response.data!));
    } else {
      emit(MyFavError(response.message ?? 'Failed to fetch payment methods'));
    }
  }
  Future<void> _onToggleLikeFoodFav(
    ToggleLikeFoodFav event,
    Emitter<MyFavState> emit,
  ) async {
    if (state is! MyFavLoaded) return;

    final current = state as MyFavLoaded;

    final updatedFoods = event.isCurrentlyLiked
        ? current.foods.where((food) => food.id.toString() != event.foodId).toList()
        : current.foods.map((food) {
            if (food.id.toString() == event.foodId) {
              return food.copyWith(isLike: true);
            }
            return food;
          }).toList();

    emit(MyFavLoaded(updatedFoods)); 

    try {
      if (event.isCurrentlyLiked) {
        await foodRepository.unlikeFood(event.foodId);
      } else {
        await foodRepository.likeFood(event.foodId);
      }
    } catch (e) {
      emit(current);
    }
  }
}