import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/profile/bloc/current/current_user_event.dart';
import 'package:foodapin/features/profile/bloc/current/current_user_state.dart';

class CurrentUserBloc extends Bloc<CurrentUserEvent, CurrentUserState> {
  final UserRepository userRepository;

  CurrentUserBloc({required this.userRepository})
      : super(CurrentUserInitial()) {

    on<GetCurrentUser>((event, emit) async {
      emit(CurrentUserLoading());

      final response = await userRepository.getCurrentUser();

      if (response.success && response.data != null) {
        emit(CurrentUserLoaded(response.data!));
      } else {
        emit(CurrentUserError(
          response.message ?? 'Failed to fetch user',
        ));
      }
    });
  }
}