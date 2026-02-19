import 'package:equatable/equatable.dart';

abstract class MyFavEvent extends Equatable {
  const MyFavEvent();

  @override
  List<Object?> get props => [];
}

class FetchFavFoods extends MyFavEvent {
  final bool isRefresh;

  const FetchFavFoods({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreFoods extends MyFavEvent {
  const LoadMoreFoods();
}

class SearchFoods extends MyFavEvent {
  final String keyword;

  const SearchFoods(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class SortFoods extends MyFavEvent {
  final String sortKey;

  const SortFoods({required this.sortKey});

  @override
  List<Object?> get props => [sortKey];
}

class ClearSearchAndSort extends MyFavEvent {
  const ClearSearchAndSort();
}
class ToggleLikeFoodFav extends MyFavEvent {
  final String foodId;
  final bool isCurrentlyLiked;

  const ToggleLikeFoodFav({
    required this.foodId,
    required this.isCurrentlyLiked,
  });
}