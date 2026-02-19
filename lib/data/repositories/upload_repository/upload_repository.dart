import 'dart:io';

import 'package:foodapin/core/base/api_response.dart';

abstract class UploadRepository {
  Future<ApiResponse<String>> uploadImage(File file);
}