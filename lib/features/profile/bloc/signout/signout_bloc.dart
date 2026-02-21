import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'package:foodapin/features/profile/bloc/signout/signout_event.dart';
import 'package:foodapin/features/profile/bloc/signout/signout_state.dart';

class SignOutBloc extends Bloc<SignOutEvent, SignOutState> {
  final AuthRepository authRepository;

  SignOutBloc(this.authRepository) : super(SignOutInitial()) {
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<SignOutState> emit,
  ) async {
    emit(SignOutLoading());

    final result = await authRepository.signOut();

    if (result.success) {
      emit(SignOutSuccess());
    } else {
      emit(SignOutFailure(result.message ?? 'SignOut failed'));
    }
  }
}