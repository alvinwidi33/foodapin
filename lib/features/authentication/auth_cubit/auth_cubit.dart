import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodapin/data/repositories/auth_repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository)
      : super(const AuthState(AuthStatus.initial));

  Future<void> checkAuth() async {
    final isLoggedIn = await authRepository.isLoggedIn();

    emit(
      AuthState(
        isLoggedIn
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
      ),
    );
  }

  Future<void> logout() async {
    await authRepository.signOut();
    emit(const AuthState(AuthStatus.unauthenticated));
  }
}
