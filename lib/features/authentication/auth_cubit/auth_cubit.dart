import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository)
      : super(const AuthState(status: AuthStatus.initial));

  Future<void> checkAuth() async {
    final isLoggedIn = await authRepository.isLoggedIn();

    emit(
      AuthState(
        status: isLoggedIn
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ),
    );
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
