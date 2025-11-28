import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/core/utils/api_response.dart';

class ApiService {
  static final Map<String, Dio> _dioInstances = {};
  static bool _initialized = false;

  static void initialize() {
    if (_initialized) return;

    // Initialize Dio instances for each microservice
    _initializeDioInstance('auth', ApiConstants.authBaseUrl);
    _initializeDioInstance('user', ApiConstants.userBaseUrl);
    _initializeDioInstance('organization', ApiConstants.organizationBaseUrl);
    _initializeDioInstance('department', ApiConstants.departmentBaseUrl);
    _initializeDioInstance('designation', ApiConstants.designationBaseUrl);
    _initializeDioInstance('vendor', ApiConstants.vendorBaseUrl);

    _initialized = true;
    print('✅ [ApiService] Initialized with microservices architecture');
  }

  static void _initializeDioInstance(String serviceName, String baseUrl) {
    final dio = Dio();
    dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 [$serviceName] $obj'),
    ));

    _dioInstances[serviceName] = dio;
    print('✅ [ApiService] $serviceName service initialized: $baseUrl');
  }

  static Dio _getDioInstance(String endpoint) {
    // Route to appropriate microservice based on endpoint
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('/tenants')) {
      return _dioInstances['auth']!;
    } else if (endpoint.startsWith('/users/')) {
      return _dioInstances['user']!;
    } else if (endpoint.startsWith('/organizations/')) {
      return _dioInstances['organization']!;
    } else if (endpoint.startsWith('/departments/')) {
      return _dioInstances['department']!;
    } else if (endpoint.startsWith('/designations/')) {
      return _dioInstances['designation']!;
    } else if (endpoint.startsWith('/vendors/')) {
      return _dioInstances['vendor']!;
    }
    
    // Default to auth service for backward compatibility
    return _dioInstances['auth']!;
  }

  // GET request
  static Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final dio = _getDioInstance(path);
      final response = await dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST request
  static Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final dio = _getDioInstance(path);
      final response = await dio.post(path, data: data, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT request
  static Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final dio = _getDioInstance(path);
      final response = await dio.put(path, data: data, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE request
  static Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final dio = _getDioInstance(path);
      final response = await dio.delete(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle successful response
  static ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      
      // Check if response follows standard format {success, message, data}
      if (responseData is Map<String, dynamic> && responseData.containsKey('success')) {
        return ApiResponse.fromJson(responseData, fromJson);
      } 
      // Handle direct data response (like tenant creation API)
      else {
        T? parsedData;
        if (fromJson != null) {
          parsedData = fromJson(responseData);
        } else {
          parsedData = responseData as T?;
        }
        
        return ApiResponse.success(
          message: response.statusCode == 201 ? 'Created successfully' : 'Success',
          data: parsedData,
        );
      }
    } else {
      return ApiResponse.error(
        message: 'Request failed with status: ${response.statusCode}',
      );
    }
  }

  // Handle errors
  static ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error(
            message: 'Connection timeout. Please check your internet connection.',
          );
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          
          if (statusCode == 401) {
            return ApiResponse.error(message: 'Unauthorized access! Please Check Your Credentials');
          } else if (statusCode == 403) {
            return ApiResponse.error(message: 'Access forbidden');
          } else if (statusCode == 404) {
            return ApiResponse.error(message: 'Resource not found');
          } else if (statusCode == 500) {
            return ApiResponse.error(message: 'Internal server error');
          }
          
          // Try to extract error message from response
          if (responseData is Map<String, dynamic>) {
            final message = responseData['message'] ?? 'Request failed';
            final errors = responseData['errors'];
            return ApiResponse.error(message: message, errors: errors);
          }
          
          return ApiResponse.error(
            message: 'Request failed with status: $statusCode',
          );
        case DioExceptionType.cancel:
          return ApiResponse.error(message: 'Request was cancelled');
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return ApiResponse.error(
              message: 'No internet connection. Please check your network.',
            );
          }
          return ApiResponse.error(
            message: 'An unexpected error occurred: ${error.message}',
          );
        default:
          return ApiResponse.error(
            message: 'An unexpected error occurred',
          );
      }
    }
    
    return ApiResponse.error(
      message: 'An unexpected error occurred: $error',
    );
  }
}

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for certain endpoints (no authentication required)
    final skipAuthPaths = [
      ApiConstants.login,
      ApiConstants.createTenant, // Step 1: No auth required
      ApiConstants.createOrganization, // Step 2: No auth required
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
      ApiConstants.sendResetEmail,
    ];

    final shouldSkipAuth = skipAuthPaths.any((path) => options.path.contains(path));

    if (!shouldSkipAuth) {
      // Check if token will expire soon and refresh if needed
      if (await JwtTokenManager.willExpireSoon()) {
        await _refreshToken();
      }

      // Add access token to headers (try new format first)
      final accessToken = await JwtTokenManager.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      // Attach tenant context header only for endpoints that require it.
      if (_shouldAttachTenantHeader(options.path)) {
        final tenantId = await JwtTokenManager.getTenantId();
        if (tenantId != null && tenantId.isNotEmpty) {
          options.headers['tenant_id'] = tenantId;
          options.headers['tenant-id'] = tenantId;
        }
      }

    }

    handler.next(options);
  }

  bool _shouldAttachTenantHeader(String path) {
    // Skip tenant headers for endpoints that have CORS issues
    const skipTenantHeaderPaths = [
      '/permissions',
      '/departments',   // Backend CORS doesn't allow tenant_id header
      '/designations',  // Backend CORS doesn't allow tenant_id header
      '/roles',         // Backend CORS doesn't allow tenant_id header
    ];

    final shouldSkip = skipTenantHeaderPaths.any((skipPath) => path.contains(skipPath));
    return !shouldSkip;
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors with token refresh and retry
    if (err.response?.statusCode == 401) {
      final refreshSuccess = await _refreshToken();
      
      if (refreshSuccess) {
        // Retry the original request with new token
        final accessToken = await JwtTokenManager.getAccessToken();
        if (accessToken != null) {
          err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          
          try {
            final dio = Dio();
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
          }
        }
      } else {
        // Refresh failed, clear tokens and let error propagate
        await JwtTokenManager.clearTokens();
      }
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await JwtTokenManager.getRefreshToken();
      if (refreshToken == null) {
        print('⚠️ [AuthInterceptor] No refresh token available');
        return false;
      }

      print('🔄 [AuthInterceptor] Attempting token refresh...');

      // Use auth service for token refresh
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.authBaseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ [AuthInterceptor] Token refresh successful');
        
        // Save new tokens with extended expiry
        await JwtTokenManager.saveLoginTokens(
          token: data['token'] ?? data['access_token'],
          refreshToken: data['refresh_token'],
          userId: data['user_id'] ?? data['userId'],
          email: data['email'],
          name: data['name'] ?? data['username'],
          tenantId: data['tenant_id'] ?? data['tenantId'],
          orgId: data['org_id'] ?? data['orgId'],
          tokenExpiresAt: data['token_expires_at'] ?? data['tokenExpiresAt'],
          refreshExpiresAt: data['refresh_expires_at'] ?? data['refreshExpiresAt'],
          roles: data['roles'] ?? [],
          permissions: data['permissions'] ?? [],
          lastLoginAt: data['last_login_at'] ?? data['lastLoginAt'],
          lastLoginIp: data['last_login_ip'] ?? data['lastLoginIp'],
        );
        
        return true;
      } else {
        print('❌ [AuthInterceptor] Token refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ [AuthInterceptor] Token refresh error: $e');
    }
    return false;
  }
}
