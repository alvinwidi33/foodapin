import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/foods.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FoodRepository foodRepository;

  static const int _pageSize = 10;

  HomeBloc({required this.foodRepository}) : super(HomeInitial()) {
    on<FetchFoods>(_onFetchFoods);
    on<LoadMoreFoods>(_onLoadMoreFoods);
    on<SearchFoods>(_onSearchFoods);
    on<SortFoods>(_onSortFoods);
    on<ClearSearchAndSort>(_onClearSearchAndSort);
  }

  Future<void> _onFetchFoods(
    FetchFoods event,
    Emitter<HomeState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(HomeLoading());
    }

    final ApiResponse<List<Foods>> result =
        await foodRepository.getAllFoods();

    if (!result.success || result.data == null) {
      emit(HomeError(result.message ?? 'Failed to load foods'));
      return;
    }

    final foods = result.data!;

    emit(HomeLoaded(
      allFoods: foods,
      visibleFoods: foods.take(_pageSize).toList(),
    ));
  }

  void _onLoadMoreFoods(
    LoadMoreFoods event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    if (current.isLoadingMore) return;
    if (current.visibleFoods.length >= current.allFoods.length) return;

    emit(current.copyWith(isLoadingMore: true));

    final next = current.allFoods
        .skip(current.visibleFoods.length)
        .take(_pageSize)
        .toList();

    emit(current.copyWith(
      visibleFoods: [...current.visibleFoods, ...next],
      isLoadingMore: false,
    ));
  }

  void _onSearchFoods(
    SearchFoods event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final filtered = current.allFoods.where((food) {
      return food.name
          .toLowerCase()
          .contains(event.keyword.toLowerCase());
    }).toList();

    emit(current.copyWith(
      searchKeyword: event.keyword,
      visibleFoods: filtered.take(_pageSize).toList(),
    ));
  }

  void _onSortFoods(
    SortFoods event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    final sorted = List<Foods>.from(current.allFoods);

    switch (event.sortKey) {
      case 'name_asc':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    emit(current.copyWith(
      sortBy: event.sortKey,
      allFoods: sorted,
      visibleFoods: sorted.take(_pageSize).toList(),
    ));
  }

  void _onClearSearchAndSort(
    ClearSearchAndSort event,
    Emitter<HomeState> emit,
  ) {
    if (state is! HomeLoaded) return;
    final current = state as HomeLoaded;

    emit(current.copyWith(
      searchKeyword: '',
      sortBy: null,
      visibleFoods: current.allFoods.take(_pageSize).toList(),
      clearSort: true,
    ));
  }
}
