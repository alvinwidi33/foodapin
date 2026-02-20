import 'package:equatable/equatable.dart';

class CreateFoodState extends Equatable {
  final bool isLoading;
  final bool isUploadingImage;
  final String? imageUrl;
  final String? errorMessage;
  final bool success;

  const CreateFoodState({
    this.isLoading = false,
    this.isUploadingImage = false,
    this.imageUrl,
    this.errorMessage,
    this.success = false,
  });

  CreateFoodState copyWith({
    bool? isLoading,
    bool? isUploadingImage,
    String? imageUrl,
    String? errorMessage,
    bool? success,
  }) {
    return CreateFoodState(
      isLoading: isLoading ?? this.isLoading,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      imageUrl: imageUrl ?? this.imageUrl,
      errorMessage: errorMessage,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isUploadingImage, imageUrl, errorMessage, success];
}