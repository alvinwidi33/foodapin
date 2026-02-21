import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_event.dart';
import 'package:foodapin/features/authentication/signin/bloc/signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SignInBloc({
    required this.authRepository,
    required this.userRepository,
  }) : super(SignInInitial()) {
    on<SignInWithEmailEvent>(_onSignIn);
  }

  Future<void> _onSignIn(
    SignInWithEmailEvent event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading());

    final loginResult = await authRepository.signIn(
    email: event.email,
    password: event.password,
  );

  if (!loginResult.success) {
    emit(SignInError(
      loginResult.message ?? 'Email atau password salah',
    ));
    return;
  }

  final userResult = await userRepository.getCurrentUser();

  if (!userResult.success || userResult.data == null) {
    emit(SignInError(
      userResult.message ?? 'Gagal mengambil data user',
    ));
    return;
  }
  emit(SignInSuccess(userResult.data!));
  }

}
