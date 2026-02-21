import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

class UpdateProfileBloc
    extends Bloc<UpdateProfileEvent, UpdateProfileState> {

  final UserRepository userRepository;
  final UploadRepository uploadRepository;

  UpdateProfileBloc({
    required this.userRepository,
    required this.uploadRepository,
  }) : super(const UpdateProfileState()) {

    on<UploadProfileImage>((event, emit) async {
      emit(state.copyWith(isUploadingImage: true));

      final result =
          await uploadRepository.uploadImage(event.file);

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

    on<SubmitUpdateProfile>((event, emit) async {
      emit(state.copyWith(isLoading: true));

      final result =
          await userRepository.updateProfile(event.user);

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