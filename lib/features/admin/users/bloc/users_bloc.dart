import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository userRepository;

  UsersBloc({required this.userRepository}) : super(UsersInitial()) {
    on<FetchUsersEvent>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsersEvent event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());

    final response = await userRepository.getAllUsers();

    if (response.success && response.data != null) {
      emit(UsersLoaded(response.data!));
    } else {
      emit(UsersError(response.message ?? 'Failed to fetch users'));
    }
  }
}