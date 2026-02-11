import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchFoods extends HomeEvent {
  final bool isRefresh;

  const FetchFoods({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreFoods extends HomeEvent {
  const LoadMoreFoods();
}

class SearchFoods extends HomeEvent {
  final String keyword;

  const SearchFoods(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class SortFoods extends HomeEvent {
  final String sortKey;

  const SortFoods({required this.sortKey});

  @override
  List<Object?> get props => [sortKey];
}

class ClearSearchAndSort extends HomeEvent {
  const ClearSearchAndSort();
}
