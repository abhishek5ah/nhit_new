import 'package:dio/dio.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart';
import 'package:ppv_components/core/utils/api_response.dart';

/// Repository for Organization API operations
/// Implements tenant-isolated organization management
class OrganizationsApiRepository {
  final Dio _dio;

  OrganizationsApiRepository() : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.authBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Add authorization header to requests
  Future<void> _addAuthHeader() async {
    final token = await JwtTokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Get organizations for current tenant (TENANT-FILTERED)
  /// Uses: GET /tenants/{tenantId}/organizations
  Future<ApiResponse<OrganizationsListResponse>> getOrganizationsByTenant(String tenantId) async {
    try {
      print('🏢 [OrganizationsApiRepository] Fetching organizations for tenant: $tenantId');
      await _addAuthHeader();
      
      final response = await _dio.get('/tenants/$tenantId/organizations');

      if (response.statusCode == 200) {
        print('✅ [OrganizationsApiRepository] Organizations retrieved successfully');
        final rawBody = response.data;
        final payload = rawBody is Map<String, dynamic> && rawBody.containsKey('data')
            ? rawBody['data']
            : rawBody;
        final organizationsResponse = OrganizationsListResponse.fromJson(
          payload ?? <String, dynamic>{},
        );
        return ApiResponse.success(
          message: 'Organizations retrieved successfully',
          data: organizationsResponse,
        );
      } else {
        print('❌ [OrganizationsApiRepository] Failed: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to retrieve organizations');
      }
    } on DioException catch (e) {
      print('🚨 [OrganizationsApiRepository] DioException: ${e.message}');
      if (e.response?.statusCode == 401) {
        return ApiResponse.error(message: 'Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        return ApiResponse.error(message: 'Access denied.');
      }
      return ApiResponse.error(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [OrganizationsApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Get single organization by ID
  /// Uses: GET /organizations/{orgId}
  Future<ApiResponse<OrganizationModel>> getOrganizationById(String orgId) async {
    try {
      print('🏢 [OrganizationsApiRepository] Getting organization by ID: $orgId');
      await _addAuthHeader();
      
      final response = await _dio.get('/organizations/$orgId');
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationsApiRepository] Organization retrieved successfully');
        final organization = OrganizationModel.fromJson(response.data['organization'] ?? response.data);
        return ApiResponse.success(
          message: 'Organization retrieved successfully',
          data: organization,
        );
      } else {
        print('❌ [OrganizationsApiRepository] Failed: ${response.statusCode}');
        return ApiResponse.error(message: 'Organization not found');
      }
    } on DioException catch (e) {
      print('🚨 [OrganizationsApiRepository] DioException: ${e.message}');
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(message: 'Organization not found');
      }
      return ApiResponse.error(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [OrganizationsApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Get organization by code
  /// Uses: GET /organizations/code/{code}
  Future<ApiResponse<OrganizationModel>> getOrganizationByCode(String code) async {
    try {
      print('🏢 [OrganizationsApiRepository] Getting organization by code: $code');
      await _addAuthHeader();
      
      final response = await _dio.get('/organizations/code/$code');
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationsApiRepository] Organization retrieved successfully');
        final organization = OrganizationModel.fromJson(response.data['organization'] ?? response.data);
        return ApiResponse.success(
          message: 'Organization retrieved successfully',
          data: organization,
        );
      } else {
        return ApiResponse.error(message: 'Organization not found');
      }
    } on DioException catch (e) {
      print('🚨 [OrganizationsApiRepository] DioException: ${e.message}');
      return ApiResponse.error(message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [OrganizationsApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Create new organization
  /// Uses: POST /organizations
  Future<ApiResponse<OrganizationModel>> createOrganization(CreateOrganizationRequest request) async {
    try {
      print('🏢 [OrganizationsApiRepository] Creating organization: ${request.name}');
      await _addAuthHeader();
      
      final response = await _dio.post(
        '/organizations',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [OrganizationsApiRepository] Organization created successfully');
        final organization = OrganizationModel.fromJson(response.data['organization'] ?? response.data);
        return ApiResponse.success(
          message: response.data['message'] ?? 'Organization created successfully',
          data: organization,
        );
      } else {
        return ApiResponse.error(message: 'Failed to create organization');
      }
    } on DioException catch (e) {
      print('🚨 [OrganizationsApiRepository] DioException: ${e.message}');
      final errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to create organization';
      return ApiResponse.error(message: errorMsg);
    } catch (e) {
      print('🚨 [OrganizationsApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Get child organizations for a parent
  /// Uses: GET /organizations/{parentOrgId}/children
  Future<ApiResponse<OrganizationsListResponse>> getChildOrganizations(String parentOrgId) async {
    try {
      print('🌿 [OrganizationsApiRepository] Fetching children for parent: $parentOrgId');
      await _addAuthHeader();

      final response = await _dio.get('/organizations/$parentOrgId/children');

      if (response.statusCode == 200) {
        final rawBody = response.data;
        final payload = rawBody is Map<String, dynamic> && rawBody.containsKey('data')
            ? rawBody['data']
            : rawBody;
        final children = OrganizationsListResponse.fromJson(
          payload ?? <String, dynamic>{},
        );
        return ApiResponse.success(
          message: response.data['message'] ?? 'Child organizations retrieved successfully',
          data: children,
        );
      } else {
        return ApiResponse.error(message: 'Failed to retrieve child organizations');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to load child organizations';
      return ApiResponse.error(message: errorMsg);
    } catch (e) {
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Update organization
  /// Uses: PUT /organizations/{orgId}
  Future<ApiResponse<OrganizationModel>> updateOrganization(String orgId, UpdateOrganizationRequest request) async {
    try {
      print('🏢 [OrganizationsApiRepository] Updating organization: $orgId');
      await _addAuthHeader();
      
      final response = await _dio.put(
        '/organizations/$orgId',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        print('✅ [OrganizationsApiRepository] Organization updated successfully');
        final organization = OrganizationModel.fromJson(response.data['organization'] ?? response.data);
        return ApiResponse.success(
          message: response.data['message'] ?? 'Organization updated successfully',
          data: organization,
        );
      } else {
        return ApiResponse.error(message: 'Failed to update organization');
      }
    } on DioException catch (e) {
      print('🚨 [OrganizationsApiRepository] DioException: ${e.message}');
      final errorMsg = e.response?.data['message'] ?? e.response?.data['error'] ?? 'Failed to update organization';
      return ApiResponse.error(message: errorMsg);
    } catch (e) {
      print('🚨 [OrganizationsApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Validate tenant access to organization
  bool validateTenantAccess(OrganizationModel organization, String userTenantId) {
    if (organization.tenantId != userTenantId) {
      print('⚠️ [OrganizationsApiRepository] Tenant mismatch! Org: ${organization.tenantId}, User: $userTenantId');
      return false;
    }
    return true;
  }
}
