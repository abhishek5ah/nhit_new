import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/auth/data/models/auth_response.dart';
import 'package:ppv_components/features/auth/data/models/forgot_password_request.dart';
import 'package:ppv_components/features/auth/data/models/login_request.dart';
import 'package:ppv_components/features/auth/data/models/register_request.dart';
import 'package:ppv_components/features/auth/data/models/reset_password_request.dart';
import 'package:ppv_components/features/auth/data/models/verify_email_request.dart';
import 'package:ppv_components/features/auth/data/models/super_admin_register_request.dart';
import 'package:ppv_components/features/auth/data/models/organization_request.dart';
import 'package:ppv_components/features/auth/data/models/organization_response.dart';
import 'package:ppv_components/features/auth/data/models/tenant_request.dart';
import 'package:ppv_components/features/auth/data/models/tenant_response.dart';
import 'package:ppv_components/features/auth/data/models/login_response.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  // Register new user (old method - kept for compatibility)
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    return await ApiService.post<AuthResponse>(
      ApiConstants.register,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  // Step 1: Super Admin Registration (DEPRECATED - Use createTenant instead)
  Future<ApiResponse<AuthResponse>> registerSuperAdmin(SuperAdminRegisterRequest request) async {
    return await ApiService.post<AuthResponse>(
      ApiConstants.register,
      data: request.toJson(),
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  // NEW Step 1: Create Tenant (Replaces registerSuperAdmin)
  Future<ApiResponse<TenantResponse>> createTenant(TenantRequest request) async {
    try {
      print('🏢 [AuthRepository] Creating tenant: ${request.email}');
      
      // Use User Service (port 8052) for tenant creation
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.userBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      
      final response = await dio.post(
        ApiConstants.createTenant,
        data: request.toJson(),
      );
      
      print('📥 [AuthRepository] Tenant response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [AuthRepository] Tenant creation successful');
        return ApiResponse.success(
          message: response.data['message'] ?? 'Tenant created successfully',
          data: TenantResponse.fromJson(response.data),
          statusCode: response.statusCode,
        );
      } else {
        print('❌ [AuthRepository] Tenant creation failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to create tenant',
          statusCode: response.statusCode,
          errorData: response.data is Map<String, dynamic> ? response.data : null,
        );
      }
    } on DioException catch (e) {
      print('🚨 [AuthRepository] DioException in createTenant: ${e.message}');
      
      final statusCode = e.response?.statusCode ?? 500;
      final responseData = e.response?.data;
      String errorMessage = 'Failed to create tenant';
      
      // Extract error message from response
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 
                        responseData['error'] ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      print('🔴 [AuthRepository] Error message: $errorMessage');
      
      return ApiResponse.error(
        message: errorMessage,
        statusCode: statusCode,
        errorData: responseData is Map<String, dynamic> ? responseData : null,
      );
    } catch (e) {
      print('🚨 [AuthRepository] Exception in createTenant: $e');
      return ApiResponse.error(
        message: 'Failed to create tenant: $e',
        statusCode: 500,
      );
    }
  }

  // Step 2: Create Organization - Uses Organization Service
  Future<ApiResponse<OrganizationResponse>> createOrganization(OrganizationRequest request) async {
    try {
      print('🏢 [AuthRepository] Creating organization: ${request.name}');
      
      // Use Organization Service (port 8053) for organization creation
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.organizationBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      
      final response = await dio.post(
        ApiConstants.createOrganization,
        data: request.toJson(),
      );
      
      print('📥 [AuthRepository] Organization response status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [AuthRepository] Organization creation successful');
        return ApiResponse.success(
          message: response.data['message'] ?? 'Organization created successfully',
          data: OrganizationResponse.fromJson(response.data),
          statusCode: response.statusCode,
        );
      } else {
        print('❌ [AuthRepository] Organization creation failed: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to create organization',
          statusCode: response.statusCode,
          errorData: response.data is Map<String, dynamic> ? response.data : null,
        );
      }
    } on DioException catch (e) {
      print('🚨 [AuthRepository] DioException in createOrganization: ${e.message}');
      
      final statusCode = e.response?.statusCode ?? 500;
      final responseData = e.response?.data;
      String errorMessage = 'Failed to create organization';
      
      // Extract error message from response
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 
                        responseData['error'] ?? 
                        errorMessage;
        } else if (responseData is String) {
          errorMessage = responseData;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      print('🔴 [AuthRepository] Error message: $errorMessage');
      
      return ApiResponse.error(
        message: errorMessage,
        statusCode: statusCode,
        errorData: responseData is Map<String, dynamic> ? responseData : null,
      );
    } catch (e) {
      print('🚨 [AuthRepository] Exception in createOrganization: $e');
      return ApiResponse.error(
        message: 'Failed to create organization: $e',
        statusCode: 500,
      );
    }
  }

  // Step 3: Login user (returns JWT tokens)
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    return await ApiService.post<LoginResponse>(
      ApiConstants.login,
      data: request.toJson(),
      fromJson: (json) => LoginResponse.fromJson(json),
    );
  }

  // Logout user
  Future<ApiResponse<void>> logout() async {
    return await ApiService.post<void>(
      ApiConstants.logout,
    );
  }

  // Verify email
  Future<ApiResponse<void>> verifyEmail(VerifyEmailRequest request) async {
    return await ApiService.post<void>(
      ApiConstants.verifyEmail,
      data: request.toJson(),
    );
  }

  // Send verification email
  Future<ApiResponse<void>> sendVerificationEmail() async {
    return await ApiService.post<void>(
      ApiConstants.sendVerification,
    );
  }

  // Forgot password
  Future<ApiResponse<void>> forgotPassword(ForgotPasswordRequest request) async {
    return await ApiService.post<void>(
      ApiConstants.forgotPassword,
      data: request.toJson(),
    );
  }

  // Reset password
  Future<ApiResponse<void>> resetPassword(ResetPasswordRequest request) async {
    return await ApiService.post<void>(
      ApiConstants.resetPassword,
      data: request.toJson(),
    );
  }

  // Send reset email
  Future<ApiResponse<void>> sendResetEmail(String email) async {
    return await ApiService.post<void>(
      ApiConstants.sendResetEmail,
      data: {'email': email},
    );
  }

  // SSO Initiate
  Future<ApiResponse<Map<String, dynamic>>> ssoInitiate(String provider) async {
    return await ApiService.post<Map<String, dynamic>>(
      ApiConstants.ssoInitiate,
      data: {'provider': provider},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // SSO Complete
  Future<ApiResponse<AuthResponse>> ssoComplete(
    String provider,
    String idToken,
  ) async {
    return await ApiService.post<AuthResponse>(
      ApiConstants.ssoComplete,
      data: {
        'provider': provider,
        'idToken': idToken,
      },
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }

  // SSO Logout Initiate
  Future<ApiResponse<Map<String, dynamic>>> ssoLogoutInitiate(
    String provider,
  ) async {
    return await ApiService.post<Map<String, dynamic>>(
      ApiConstants.ssoLogoutInitiate,
      data: {'provider': provider},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // SSO Logout Complete
  Future<ApiResponse<void>> ssoLogoutComplete(
    String provider,
    String logoutToken,
  ) async {
    return await ApiService.post<void>(
      ApiConstants.ssoLogoutComplete,
      data: {
        'provider': provider,
        'logoutToken': logoutToken,
      },
    );
  }

  // Refresh token
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    return await ApiService.post<AuthResponse>(
      ApiConstants.refreshToken,
      data: {'refreshToken': refreshToken},
      fromJson: (json) => AuthResponse.fromJson(json),
    );
  }
}
