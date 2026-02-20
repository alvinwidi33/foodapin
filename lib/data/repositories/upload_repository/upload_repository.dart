
import 'package:foodapin/core/base/api_response.dart';
import 'package:image_picker/image_picker.dart';

abstract class UploadRepository {
  Future<ApiResponse<String>> uploadImage(XFile file);
}