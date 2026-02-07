import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,        
  authenticated, 
  unauthenticated
}

class AuthState extends Equatable {
  final AuthStatus status;

  const AuthState(this.status);

  @override
  List<Object?> get props => [status];
}
