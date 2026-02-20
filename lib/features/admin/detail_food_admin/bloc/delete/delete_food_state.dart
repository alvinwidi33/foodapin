import 'package:equatable/equatable.dart';

class DeleteFoodState extends Equatable {
  final bool isLoading;
  final bool success;
  final String? errorMessage;

  const DeleteFoodState({
    this.isLoading = false,
    this.success = false,
    this.errorMessage,
  });

  DeleteFoodState copyWith({
    bool? isLoading,
    bool? success,
    String? errorMessage,
  }) {
    return DeleteFoodState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, success, errorMessage];
}