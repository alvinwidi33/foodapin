import 'dart:io';

import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';

class UploadRepositoryImpl implements UploadRepository {
  final Dio dio;

  UploadRepositoryImpl(this.dio);

  Future<ApiResponse<String>> uploadImage(File file) async {
    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final res = await dio.post(
        "/api/v1/upload-image",
        data: formData,
      );

      return ApiResponse.success(
        res.data["data"]?["url"], 
        message: res.data['message']
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data["message"] ?? "Upload failed",
      );
    }
  }
}
