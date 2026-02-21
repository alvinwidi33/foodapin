import 'package:equatable/equatable.dart';

class UpdateProfileState extends Equatable {
  final bool isUploadingImage;
  final bool isLoading;
  final bool success;
  final String? imageUrl;
  final String? errorMessage;

  const UpdateProfileState({
    this.isUploadingImage = false,
    this.isLoading = false,
    this.success = false,
    this.imageUrl,
    this.errorMessage,
  });

  UpdateProfileState copyWith({
    bool? isUploadingImage,
    bool? isLoading,
    bool? success,
    String? imageUrl,
    String? errorMessage,
  }) {
    return UpdateProfileState(
      isUploadingImage:
          isUploadingImage ?? this.isUploadingImage,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      imageUrl: imageUrl ?? this.imageUrl,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isUploadingImage,
        isLoading,
        success,
        imageUrl,
        errorMessage,
      ];
}