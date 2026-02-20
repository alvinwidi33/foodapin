import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/foods.dart';

abstract class FoodsAdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FoodsAdminInitial extends FoodsAdminState {}

class FoodsAdminLoading extends FoodsAdminState {}

class FoodsAdminLoaded extends FoodsAdminState {
  final List<Foods> allFoods;
  final List<Foods> visibleFoods;
  final bool isLoadingMore;
  final String searchKeyword;
  final String? sortBy;

  FoodsAdminLoaded({
    required this.allFoods,
    required this.visibleFoods,
    this.isLoadingMore = false,
    this.searchKeyword = '',
    this.sortBy,
  });

  FoodsAdminLoaded copyWith({
    List<Foods>? allFoods,
    List<Foods>? visibleFoods,
    bool? isLoadingMore,
    String? searchKeyword,
    String? sortBy,
    bool clearSort = false,
  }) {
    return FoodsAdminLoaded(
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

class FoodsAdminError extends FoodsAdminState {
  final String message;

  FoodsAdminError(this.message);

  @override
  List<Object?> get props => [message];
}
