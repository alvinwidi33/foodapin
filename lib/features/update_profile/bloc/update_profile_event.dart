import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/users.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => [];
}

class SubmitUpdateProfile extends UpdateProfileEvent {
  final Users user;

  const SubmitUpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}