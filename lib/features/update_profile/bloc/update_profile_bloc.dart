import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'update_profile_event.dart';
import 'update_profile_state.dart';

class UpdateProfileBloc
    extends Bloc<UpdateProfileEvent, UpdateProfileState> {

  final UserRepository userRepository;

  UpdateProfileBloc({required this.userRepository})
      : super(UpdateProfileInitial()) {
    on<SubmitUpdateProfile>(_onSubmitUpdateProfile);
  }

  Future<void> _onSubmitUpdateProfile(
    SubmitUpdateProfile event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(UpdateProfileLoading());

    final response = await userRepository.updateProfile(event.user);

    if (response.success) {
      emit(UpdateProfileSuccess());
    } else {
      emit(
        UpdateProfileFailure(
          response.message ?? 'Failed to update profile',
        ),
      );
    }
  }
}