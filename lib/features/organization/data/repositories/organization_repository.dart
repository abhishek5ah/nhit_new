import 'package:dio/dio.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/features/organization/data/models/organization_model.dart';
import 'package:ppv_components/core/utils/api_response.dart';

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
  Future<ApiResponse<Map<String, dynamic>>> switchOrganization(String orgId) async {
    try {
      print('🔄 [OrganizationRepository] Switching to organization: $orgId');
      
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
      
      final response = await dio.post(
        ApiConstants.switchOrganization,
        data: {'organization_id': orgId},
      );
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationRepository] Organization switched successfully');
        
        // Update stored org ID
        await JwtTokenManager.saveOrgId(orgId);
        
        return ApiResponse.success(
          message: 'Organization switched successfully',
          data: response.data ?? {
            'message': 'Organization switched successfully',
            'orgId': orgId,
          },
        );
      } else {
        print('❌ [OrganizationRepository] Failed to switch organization: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to switch organization');
      }
    } catch (e) {
      print('🚨 [OrganizationRepository] Exception in switchOrganization: $e');
      // Fallback: just update local storage
      await JwtTokenManager.saveOrgId(orgId);
      return ApiResponse.success(
        message: 'Organization switched locally',
        data: {'orgId': orgId},
      );
    }
  }
}
