import 'package:equatable/equatable.dart';

abstract class FoodsAdminEvent extends Equatable {
  const FoodsAdminEvent();

  @override
  List<Object?> get props => [];
}

class FetchFoodsAdmin extends FoodsAdminEvent {
  final bool isRefresh;

  const FetchFoodsAdmin({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreFoodsAdmin extends FoodsAdminEvent {
  const LoadMoreFoodsAdmin();
}

class SearchFoodsAdmin extends FoodsAdminEvent {
  final String keyword;

  const SearchFoodsAdmin(this.keyword);

  @override
  List<Object?> get props => [keyword];
}

class SortFoodsAdmin extends FoodsAdminEvent {
  final String sortKey;

  const SortFoodsAdmin({required this.sortKey});

  @override
  List<Object?> get props => [sortKey];
}

class ClearSearchAndSortAdmin extends FoodsAdminEvent {
  const ClearSearchAndSortAdmin();
}