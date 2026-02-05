import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/users.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final Users user;

  const SignUpSuccess(this.user);

  @override
  List<Object?> get props => [user];
}


class SignUpError extends SignUpState {
  final String message;

  const SignUpError(this.message);

  @override
  List<Object?> get props => [message];
}