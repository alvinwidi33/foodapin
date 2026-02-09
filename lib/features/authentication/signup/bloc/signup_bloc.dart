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

    final user = Users(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordRepeat: event.passwordRepeat,
      role: event.role,
      phoneNumber: event.phoneNumber,
      profilePictureUrl: '',
    );

    final result = await authRepository.signUp(user: user);

    if (result.success) {
      emit(SignUpSuccess(result.data!));
    } else {
      emit(SignUpError(result.message ?? 'Signup failed'));
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