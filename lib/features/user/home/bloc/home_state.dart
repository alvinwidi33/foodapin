import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/foods.dart';

abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Foods> allFoods;
  final List<Foods> visibleFoods;
  final bool isLoadingMore;
  final String searchKeyword;
  final String? sortBy;

  HomeLoaded({
    required this.allFoods,
    required this.visibleFoods,
    this.isLoadingMore = false,
    this.searchKeyword = '',
    this.sortBy,
  });

  HomeLoaded copyWith({
    List<Foods>? allFoods,
    List<Foods>? visibleFoods,
    bool? isLoadingMore,
    String? searchKeyword,
    String? sortBy,
    bool clearSort = false,
  }) {
    return HomeLoaded(
      allFoods: allFoods ?? this.allFoods,
      visibleFoods: visibleFoods ?? this.visibleFoods,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchKeyword: searchKeyword ?? this.searchKeyword,
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
    );
  }

  @override
  List<Object?> get props => [
        allFoods,
        visibleFoods,
        isLoadingMore,
        searchKeyword,
        sortBy,
      ];
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
