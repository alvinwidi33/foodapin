class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool success;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(
    T data, {
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(
    String message, {
    int? statusCode,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
