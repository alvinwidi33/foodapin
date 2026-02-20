import 'package:equatable/equatable.dart';

abstract class DeleteFoodEvent extends Equatable {
  const DeleteFoodEvent();

  @override
  List<Object?> get props => [];
}

class DeleteFoodRequested extends DeleteFoodEvent {
  final String id;

  const DeleteFoodRequested(this.id);

  @override
  List<Object?> get props => [id];
}