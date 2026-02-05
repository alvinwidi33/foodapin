import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/models/users.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_event.dart';
import 'package:foodapin/features/authentication/signup/bloc/signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SignUpBloc({required this.authRepository, required this.userRepository}) : super(SignUpInitial()) {
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<SignUpState> emit,
  ) async {
    emit(SignUpLoading());

    try {
      final user = Users(
        id: event.id,
        name: event.name,
        email: event.email,
        password: event.password,
        passwordRepeat: event.passwordRepeat,
        role: event.role,
        phoneNumber: event.phoneNumber,
        profilePictureUrl: '',
      );

      await authRepository.signUp(user: user);

      emit(SignUpSuccess(user));
    } on DioException catch (e) {
      emit(
        SignUpError(
          e.response?.data['message'] ?? 'Signup gagal',
        ),
      );
    } catch (e) {
      emit(SignUpError('Terjadi kesalahan'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<SignUpState> emit,
  ) async {
    await authRepository.signOut();
    emit(SignUpInitial());
  }
}