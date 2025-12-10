/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? error;
 
  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
  });
 
  /// Create a successful response
  factory ApiResponse.success({
    T? data,
    String? message,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }
 
  /// Create an error response
  factory ApiResponse.error({
    required String message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      error: message,
      statusCode: statusCode,
    );
  }
 
  /// Convert from JSON
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final success = json['success'] == true;
    final data = json['data'];
   
    return ApiResponse<T>(
      success: success,
      message: json['message']?.toString(),
      data: data != null && fromJsonT != null ? fromJsonT(data) : data as T?,
      statusCode: json['statusCode'] as int?,
      error: json['error']?.toString(),
    );
  }
 
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (statusCode != null) 'statusCode': statusCode,
      if (error != null) 'error': error,
    };
  }
}
 
 