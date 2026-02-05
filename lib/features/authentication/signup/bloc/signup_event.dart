import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  const SignUpEvent();

  @override
  List<Object?> get props => [];
}

class SignUpWithEmailEvent extends SignUpEvent {
  final String id;
  final String name;
  final String email;
  final String password;
  final String passwordRepeat;
  final String phoneNumber;
  final String role;

  const SignUpWithEmailEvent({required this.id, required this.name, required this.email, required this.password, required this.passwordRepeat, required this.role, required this.phoneNumber});

  @override
  List<Object?> get props => [name, email, password, passwordRepeat, role];
}


class SignOutEvent extends SignUpEvent {}