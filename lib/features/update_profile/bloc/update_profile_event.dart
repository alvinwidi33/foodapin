import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foodapin/data/models/users.dart';

abstract class UpdateProfileEvent extends Equatable {
  const UpdateProfileEvent();

  @override
  List<Object?> get props => [];
}

class UploadProfileImage extends UpdateProfileEvent {
  final XFile file;

  const UploadProfileImage(this.file);

  @override
  List<Object?> get props => [file];
}

class SubmitUpdateProfile extends UpdateProfileEvent {
  final Users user;

  const SubmitUpdateProfile(this.user);

  @override
  List<Object?> get props => [user];
}