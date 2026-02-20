import 'package:foodapin/data/models/users.dart';

abstract class CurrentUserState {}

class CurrentUserInitial extends CurrentUserState {}

class CurrentUserLoading extends CurrentUserState {}

class CurrentUserLoaded extends CurrentUserState {
  final Users user;

  CurrentUserLoaded(this.user);
}

class CurrentUserError extends CurrentUserState {
  final String message;

  CurrentUserError(this.message);
}