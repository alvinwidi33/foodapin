import 'package:dio/dio.dart';
import 'package:foodapin/core/base/api_response.dart';
import 'package:foodapin/data/repositories/upload_repository/upload_repository.dart';
import 'package:image_picker/image_picker.dart';

class UploadRepositoryImpl implements UploadRepository {
  final Dio dio;

  UploadRepositoryImpl(this.dio);

  @override
  Future<ApiResponse<String>> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();

      FormData formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        ),
      });

      final res = await dio.post(
        "/upload-image",
        data: formData,
      );

      return ApiResponse.success(
        res.data["url"],
        message: res.data['message'],
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data["message"] ?? "Upload failed",
      );
    } catch (e) {
      return ApiResponse.error("Unexpected error: $e");
    }
  }
}