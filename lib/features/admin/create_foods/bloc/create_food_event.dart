import 'package:equatable/equatable.dart';
import 'package:foodapin/data/models/foods.dart';
import 'package:image_picker/image_picker.dart';

abstract class CreateFoodEvent extends Equatable {
  const CreateFoodEvent();

  @override
  List<Object?> get props => [];
}

class UploadFoodImage extends CreateFoodEvent {
  final XFile file;

  const UploadFoodImage(this.file);

  @override
  List<Object?> get props => [file];
}

class SubmitCreateFood extends CreateFoodEvent {
  final Foods food;

  const SubmitCreateFood(this.food);

  @override
  List<Object?> get props => [food];
}