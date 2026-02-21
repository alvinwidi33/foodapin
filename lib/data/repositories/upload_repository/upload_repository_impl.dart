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

      final String filename = _resolveFilename(file);
      final String mimeType = _resolveMimeType(filename);

      final formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(
          bytes,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
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

  String _resolveFilename(XFile file) {
    final original = file.name.trim();

    final supported = ['.jpg', '.jpeg', '.png', '.webp', '.svg'];
    final lower = original.toLowerCase();
    if (supported.any((ext) => lower.endsWith(ext))) {
      return original;
    }

    if (file.mimeType != null) {
      final ext = _extFromMime(file.mimeType!);
      if (ext != null) {
        final baseName = original.isNotEmpty ? original : 'image_${DateTime.now().millisecondsSinceEpoch}';
        return '$baseName$ext';
      }
    }

    final baseName = original.isNotEmpty ? original : 'image_${DateTime.now().millisecondsSinceEpoch}';
    return '$baseName.jpg';
  }

  String _resolveMimeType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return 'image/jpeg';
  }

  String? _extFromMime(String mime) {
    switch (mime.toLowerCase()) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'image/svg+xml':
        return '.svg';
      default:
        return null;
    }
  }
}