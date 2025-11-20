class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;
  final Map<String, dynamic>? errorData;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
    this.errorData,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    print('🔍 [ApiResponse] Starting JSON parsing...');
    print('📋 [ApiResponse] JSON keys present: ${json.keys.toList()}');
    
    try {
      final success = json['success'] ?? false;
      final message = json['message'] ?? '';
      final hasData = json['data'] != null;
      final statusCode = json['statusCode'] as int?;
      
      print('✅ [ApiResponse] Success field: $success');
      print('💬 [ApiResponse] Message field: $message');
      print('📦 [ApiResponse] Data field exists: $hasData');
      print('🔢 [ApiResponse] Status code: $statusCode');
      
      T? parsedData;
      if (hasData && fromJsonT != null) {
        print('🔄 [ApiResponse] Parsing data with custom fromJson function...');
        parsedData = fromJsonT(json['data']);
        print('✅ [ApiResponse] Data parsed successfully');
      } else {
        print('📤 [ApiResponse] Using raw data (no custom parser)');
        parsedData = json['data'];
      }
      
      final response = ApiResponse<T>(
        success: success,
        message: message,
        data: parsedData,
        errors: json['errors'],
        statusCode: statusCode,
        errorData: json['errorData'] as Map<String, dynamic>?,
      );
      
      print('🎉 [ApiResponse] JSON parsing completed successfully');
      return response;
      
    } catch (e, stackTrace) {
      print('🚨 [ApiResponse] ERROR during JSON parsing:');
      print('   JSON that failed to parse: $json');
      print('   Error: $e');
      print('   Stack Trace: $stackTrace');
      print('================== PARSING ERROR END ==================');
      
      // Rethrow the error so it can be caught by calling code
      rethrow;
    }
  }

  factory ApiResponse.success({
    required String message,
    T? data,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
    Map<String, dynamic>? errorData,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
      errorData: errorData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'statusCode': statusCode,
      'errorData': errorData,
    };
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, hasData: ${data != null}, hasErrors: ${errors != null}, hasErrorData: ${errorData != null})';
  }
}
