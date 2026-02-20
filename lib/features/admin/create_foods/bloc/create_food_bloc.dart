import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/food_repository/food_repository.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'create_food_event.dart';
import 'create_food_state.dart';

class CreateFoodBloc extends Bloc<CreateFoodEvent, CreateFoodState> {
  final FoodRepository foodRepository;
  final UploadRepository uploadRepository;

  CreateFoodBloc({
    required this.foodRepository,
    required this.uploadRepository,
  }) : super(const CreateFoodState()) {

    on<UploadFoodImage>((event, emit) async {
      emit(state.copyWith(isUploadingImage: true));

      final result = await uploadRepository.uploadImage(event.file);

      if (result.success && result.data != null) {
        emit(state.copyWith(
          isUploadingImage: false,
          imageUrl: result.data,
        ));
      } else {
        emit(state.copyWith(
          isUploadingImage: false,
          errorMessage: result.message,
        ));
      }
    });

    on<SubmitCreateFood>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final result = await foodRepository.createFood(event.food);

      if (result.success) {
        emit(state.copyWith(
          isLoading: false,
          success: true,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: result.message,
        ));
      }
    });
  }
}