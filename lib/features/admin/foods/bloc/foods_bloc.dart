import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/models/foods.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/features/admin/foods/bloc/foods_event.dart';
import 'package:foodapin/features/admin/foods/bloc/foods_state.dart';


class FoodsAdminBloc extends Bloc<FoodsAdminEvent, FoodsAdminState> {
  final FoodRepository foodRepository;

  static const int _pageSize = 10;

  FoodsAdminBloc({required this.foodRepository}) : super(FoodsAdminInitial()) {
    on<FetchFoodsAdmin>(_onFetchFoods);
    on<LoadMoreFoodsAdmin>(_onLoadMoreFoods);
    on<SearchFoodsAdmin>(_onSearchFoods);
    on<SortFoodsAdmin>(_onSortFoods);
    on<ClearSearchAndSortAdmin>(_onClearSearchAndSort);
  }

  Future<void> _onFetchFoods(
    FetchFoodsAdmin event,
    Emitter<FoodsAdminState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(FoodsAdminLoading());
    }

    final ApiResponse<List<Foods>> result =
        await foodRepository.getAllFoods();

    if (!result.success || result.data == null) {
      emit(FoodsAdminError(result.message ?? 'Failed to load foods'));
      return;
    }

    final foods = result.data!;

    emit(FoodsAdminLoaded(
      allFoods: foods,
      visibleFoods: foods.take(_pageSize).toList(),
    ));
  }

  void _onLoadMoreFoods(
    LoadMoreFoodsAdmin event,
    Emitter<FoodsAdminState> emit,
  ) {
    if (state is! FoodsAdminLoaded) return;
    final current = state as FoodsAdminLoaded;

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
    SearchFoodsAdmin event,
    Emitter<FoodsAdminState> emit,
  ) {
    if (state is! FoodsAdminLoaded) return;
    final current = state as FoodsAdminLoaded;

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
    SortFoodsAdmin event,
    Emitter<FoodsAdminState> emit,
  ) {
    if (state is! FoodsAdminLoaded) return;
    final current = state as FoodsAdminLoaded;

    final sorted = List<Foods>.from(current.allFoods);

    switch (event.sortKey) {
      case 'name_asc':
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        sorted.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;

      case 'price_desc':
        sorted.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;

    }

    emit(current.copyWith(
      sortBy: event.sortKey,
      allFoods: sorted,
      visibleFoods: sorted.take(_pageSize).toList(),
    ));
  }

  void _onClearSearchAndSort(
    ClearSearchAndSortAdmin event,
    Emitter<FoodsAdminState> emit,
  ) {
    if (state is! FoodsAdminLoaded) return;
    final current = state as FoodsAdminLoaded;

    emit(current.copyWith(
      searchKeyword: '',
      sortBy: null,
      visibleFoods: current.allFoods.take(_pageSize).toList(),
      clearSort: true,
    ));
  }
}
