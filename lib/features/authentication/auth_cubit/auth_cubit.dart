import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'package:foodapin/data/repositories/user_repository/user_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthCubit(this.authRepository, this.userRepository)
      : super(const AuthState(status: AuthStatus.initial));

  Future<void> checkAuth() async {
    try {
      final isLoggedIn = await authRepository.isLoggedIn();

      if (!isLoggedIn) {
        emit(const AuthState(status: AuthStatus.unauthenticated));
        return;
      }

      final user = await userRepository.getCurrentUser();

      emit(
        AuthState(
          status: AuthStatus.authenticated,
          role: user.data?.role,
        ),
      );
    } catch (e) {
      await authRepository.signOut();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void setAuthenticated(String role) {
    emit(
      AuthState(
        status: AuthStatus.authenticated,
        role: role,
      ),
    );
  }
}
