import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,        
  authenticated, 
  unauthenticated
}

class AuthState extends Equatable {
  final AuthStatus status;
  final String? role;

  const AuthState({
    required this.status,
    this.role,
  });

  @override
  List<Object?> get props => [status, role];
}
