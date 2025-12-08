import 'package:dio/dio.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/features/organization/data/models/organization_model.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/auth/data/models/login_response.dart';

class OrganizationRepository {
  final ApiService _apiService = ApiService();

  // Get all organizations for a tenant - Uses Organization Service
  Future<ApiResponse<OrganizationsListResponse>> getOrganizations(String tenantId) async {
    try {
      print('🏢 [OrganizationRepository] Fetching organizations for tenant: $tenantId');
      
      // Use Organization Service (port 8053)
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.organizationBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      
      // Add auth token
      final token = await JwtTokenManager.getAccessToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await dio.get(
        '${ApiConstants.getOrganizationsByTenant}/$tenantId/organizations',
      );
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationRepository] Organizations retrieved successfully');
        final organizationsResponse = OrganizationsListResponse.fromJson(response.data);
        return ApiResponse.success(message: 'Organizations retrieved successfully', data: organizationsResponse);
      } else {
        print('❌ [OrganizationRepository] Failed to retrieve organizations: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to retrieve organizations');
      }
    } catch (e) {
      print('🚨 [OrganizationRepository] Exception in getOrganizations: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // Get organization by code
  Future<ApiResponse<OrganizationModel>> getOrganizationByCode(String code) async {
    try {
      print('🏢 [OrganizationRepository] Getting organization by code: $code');
      
      // Use Organization Service (port 8053) for getting organization by code
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.organizationBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      
      // Add auth token
      final token = await JwtTokenManager.getAccessToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await dio.get(
        '${ApiConstants.getOrganizationByCode}/$code',
      );
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationRepository] Organization retrieved successfully');
        final organization = OrganizationModel.fromJson(response.data['organization']);
        return ApiResponse.success(message: 'Organization retrieved successfully', data: organization);
      } else {
        print('❌ [OrganizationRepository] Failed to get organization: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to get organization');
      }
    } catch (e) {
      print('🚨 [OrganizationRepository] Exception in getOrganizationByCode: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // Update organization
  Future<ApiResponse<Map<String, dynamic>>> updateOrganization(String orgId, UpdateOrganizationRequest request) async {
    try {
      print('🏢 [OrganizationRepository] Updating organization: $orgId');
      
      // Use Organization Service (port 8053) for updating organization
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.organizationBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      
      // Add auth token
      final token = await JwtTokenManager.getAccessToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await dio.put(
        '${ApiConstants.updateOrganization}/$orgId',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationRepository] Organization updated successfully');
        return ApiResponse.success(message: 'Organization updated successfully', data: response.data);
      } else {
        print('❌ [OrganizationRepository] Failed to update organization: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to update organization');
      }
    } catch (e) {
      print('🚨 [OrganizationRepository] Exception in updateOrganization: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // Switch to organization - Uses Auth Service
  Future<ApiResponse<LoginResponse?>> switchOrganization(OrganizationModel organization) async {
    try {
      print('🔄 [OrganizationRepository] Switching to organization: ${organization.name}');
      
      // Use Auth Service (port 8051) for organization switching
      final dio = Dio(BaseOptions(
        baseUrl: ApiConstants.authBaseUrl,
        headers: {'Content-Type': 'application/json'},
      ));
      
      // Add auth token
      final token = await JwtTokenManager.getAccessToken();
      if (token != null) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }
      
      final payload = {
        'org_name': organization.name,
        'organization_id': organization.orgId,
        'org_id': organization.orgId,
        'tenant_id': organization.tenantId,
      }..removeWhere((key, value) => value == null || value.toString().isEmpty);
      
      final response = await dio.post(
        ApiConstants.switchOrganization,
        data: payload,
      );
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationRepository] Organization switched successfully');
        
        final loginResponse = LoginResponse.fromJson(response.data as Map<String, dynamic>);
        
        await JwtTokenManager.saveLoginTokens(
          token: loginResponse.token,
          refreshToken: loginResponse.refreshToken,
          userId: loginResponse.userId,
          email: loginResponse.email,
          name: loginResponse.name,
          tenantId: loginResponse.tenantId,
          orgId: loginResponse.orgId,
          tokenExpiresAt: loginResponse.tokenExpiresAt,
          refreshExpiresAt: loginResponse.refreshExpiresAt,
          roles: loginResponse.roles,
          permissions: loginResponse.permissions,
          lastLoginAt: loginResponse.lastLoginAt,
          lastLoginIp: loginResponse.lastLoginIp,
        );
        
        await JwtTokenManager.saveOrgId(loginResponse.orgId);
        
        return ApiResponse.success(
          message: response.data['message'] ?? 'Organization switched successfully',
          data: loginResponse,
          statusCode: response.statusCode,
        );
      } else {
        print('❌ [OrganizationRepository] Failed to switch organization: ${response.statusCode}');
        return ApiResponse.error(
          message: response.data['message'] ?? 'Failed to switch organization',
          statusCode: response.statusCode,
          errorData: response.data is Map<String, dynamic> ? response.data : null,
        );
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      final message = responseData is Map<String, dynamic>
          ? responseData['message']?.toString() ?? 'Failed to switch organization'
          : e.message ?? 'Failed to switch organization';
      
      print('🚨 [OrganizationRepository] DioException in switchOrganization: $message');
      
      // Backend returns 400 with message "already in this organization" when no switch needed
      if (statusCode == 400 && message.toLowerCase().contains('already in this organization')) {
        await JwtTokenManager.saveOrgId(organization.orgId);
        return ApiResponse.success(
          message: message,
          data: null,
          statusCode: statusCode,
        );
      }
      
      return ApiResponse.error(
        message: message,
        statusCode: statusCode ?? 500,
        errorData: responseData is Map<String, dynamic> ? responseData : null,
      );
    } catch (e) {
      print('🚨 [OrganizationRepository] Exception in switchOrganization: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }
}
