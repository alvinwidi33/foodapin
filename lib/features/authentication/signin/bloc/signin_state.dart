import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/users.dart';
abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {
  final Users user;

  const SignInSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class SignInError extends SignInState {
  final String message;

  const SignInError(this.message);

  @override
  List<Object?> get props => [message];
}