// ============================================================================
// USER API REPOSITORY
// Handles all HTTP requests for User Management
// Base URL: http://192.168.1.51:8083/api/v1
// ============================================================================

import 'package:dio/dio.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/features/user/data/models/user_api_models.dart';

class UserApiRepository {
  late final Dio _dio;

  UserApiRepository() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🌐 [UserAPI] $obj'),
    ));
  }

  /// Add authentication headers
  Future<void> _addAuthHeader() async {
    final token = await JwtTokenManager.getAccessToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // ============================================================================
  // 1. CREATE USER
  // POST /api/v1/users
  // ============================================================================
  Future<ApiResponse<UserApiModel>> createUser(CreateUserRequest request) async {
    try {
      print('👤 [UserApiRepository] Creating user: ${request.email}');
      await _addAuthHeader();

      final response = await _dio.post(
        ApiConstants.users,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = UserApiModel.fromJson(response.data);
        print('✅ [UserApiRepository] User created: ${user.userId}');
        return ApiResponse.success(
          message: 'User created successfully',
          data: user,
        );
      } else {
        print('❌ [UserApiRepository] Failed to create user: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to create user');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 2. GET USER DETAILS
  // GET /api/v1/users/{user_id}
  // ============================================================================
  Future<ApiResponse<UserApiModel>> getUserById(String userId) async {
    try {
      print('👤 [UserApiRepository] Fetching user: $userId');
      await _addAuthHeader();

      final response = await _dio.get('${ApiConstants.users}/$userId');

      if (response.statusCode == 200) {
        final user = UserApiModel.fromJson(response.data);
        print('✅ [UserApiRepository] User fetched: ${user.name}');
        return ApiResponse.success(
          message: 'User fetched successfully',
          data: user,
        );
      } else {
        print('❌ [UserApiRepository] Failed to fetch user: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to fetch user');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 3. LIST USERS (PAGINATED)
  // GET /api/v1/users?page=1&page_size=10
  // ============================================================================
  Future<ApiResponse<UsersListResponse>> getUsers({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      print('👥 [UserApiRepository] Fetching users - Page: $page, Size: $pageSize');
      await _addAuthHeader();

      final response = await _dio.get(
        ApiConstants.users,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final usersResponse = UsersListResponse.fromJson(response.data);
        print('✅ [UserApiRepository] Fetched ${usersResponse.users.length} users');
        return ApiResponse.success(
          message: 'Users fetched successfully',
          data: usersResponse,
        );
      } else {
        print('❌ [UserApiRepository] Failed to fetch users: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to fetch users');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 4. UPDATE USER
  // PUT /api/v1/users/{user_id}
  // ============================================================================
  Future<ApiResponse<UserApiModel>> updateUser(UpdateUserRequest request) async {
    try {
      print('👤 [UserApiRepository] Updating user: ${request.userId}');
      await _addAuthHeader();

      final response = await _dio.put(
        '${ApiConstants.users}/${request.userId}',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final user = UserApiModel.fromJson(response.data);
        print('✅ [UserApiRepository] User updated: ${user.userId}');
        return ApiResponse.success(
          message: 'User updated successfully',
          data: user,
        );
      } else {
        print('❌ [UserApiRepository] Failed to update user: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to update user');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 5. UPLOAD USER SIGNATURE
  // POST /api/v1/users/{user_id}/signature
  // ============================================================================
  Future<ApiResponse<SignatureUploadResponse>> uploadSignature(
    UploadSignatureRequest request,
  ) async {
    try {
      print('📸 [UserApiRepository] Uploading signature for: ${request.userId}');
      await _addAuthHeader();

      final response = await _dio.post(
        '${ApiConstants.users}/${request.userId}/signature',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final uploadResponse = SignatureUploadResponse.fromJson(response.data);
        print('✅ [UserApiRepository] Signature uploaded: ${uploadResponse.fileUrl}');
        return ApiResponse.success(
          message: uploadResponse.message,
          data: uploadResponse,
        );
      } else {
        print('❌ [UserApiRepository] Failed to upload signature: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to upload signature');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 6. LIST USER ORGANIZATIONS
  // GET /api/v1/users/{user_id}/organizations
  // ============================================================================
  Future<ApiResponse<UserOrganizationsResponse>> getUserOrganizations(
    String userId,
  ) async {
    try {
      print('🏢 [UserApiRepository] Fetching organizations for user: $userId');
      await _addAuthHeader();

      final response = await _dio.get(
        '${ApiConstants.users}/$userId/organizations',
      );

      if (response.statusCode == 200) {
        final orgsResponse = UserOrganizationsResponse.fromJson(response.data);
        print('✅ [UserApiRepository] Fetched ${orgsResponse.organizations.length} organizations');
        return ApiResponse.success(
          message: 'Organizations fetched successfully',
          data: orgsResponse,
        );
      } else {
        print('❌ [UserApiRepository] Failed to fetch organizations: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to fetch organizations');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 7. ADD USER TO ORGANIZATION
  // POST /api/v1/users/{user_id}/organizations
  // ============================================================================
  Future<ApiResponse<UserApiModel>> addUserToOrganization(
    AddUserToOrgRequest request,
  ) async {
    try {
      print('🏢 [UserApiRepository] Adding user ${request.userId} to org ${request.orgId}');
      await _addAuthHeader();

      final response = await _dio.post(
        '${ApiConstants.users}/${request.userId}/organizations',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = UserApiModel.fromJson(response.data);
        print('✅ [UserApiRepository] User added to organization');
        return ApiResponse.success(
          message: 'User added to organization successfully',
          data: user,
        );
      } else {
        print('❌ [UserApiRepository] Failed to add user to org: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to add user to organization');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============================================================================
  // 8. DROPDOWN ENDPOINTS
  // ============================================================================

  /// Get Departments Dropdown
  /// GET /api/v1/users/dropdowns/departments?org_id={org_id}
  Future<ApiResponse<List<DropdownItem>>> getDepartmentsDropdown(String orgId) async {
    try {
      print('📋 [UserApiRepository] Fetching departments dropdown for org: $orgId');
      await _addAuthHeader();

      final response = await _dio.get(
        '${ApiConstants.users}/dropdowns/departments',
        queryParameters: {'org_id': orgId},
      );

      if (response.statusCode == 200) {
        final dropdownResponse = DepartmentsDropdownResponse.fromJson(response.data);
        print('✅ [UserApiRepository] Fetched ${dropdownResponse.departments.length} departments');
        return ApiResponse.success(
          message: 'Departments fetched successfully',
          data: dropdownResponse.departments,
        );
      } else {
        print('❌ [UserApiRepository] Failed to fetch departments: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to fetch departments');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Get Designations Dropdown
  /// GET /api/v1/users/dropdowns/designations?org_id={org_id}
  Future<ApiResponse<List<DropdownItem>>> getDesignationsDropdown(String orgId) async {
    try {
      print('📋 [UserApiRepository] Fetching designations dropdown for org: $orgId');
      await _addAuthHeader();

      final response = await _dio.get(
        '${ApiConstants.users}/dropdowns/designations',
        queryParameters: {'org_id': orgId},
      );

      if (response.statusCode == 200) {
        final dropdownResponse = DesignationsDropdownResponse.fromJson(response.data);
        print('✅ [UserApiRepository] Fetched ${dropdownResponse.designations.length} designations');
        return ApiResponse.success(
          message: 'Designations fetched successfully',
          data: dropdownResponse.designations,
        );
      } else {
        print('❌ [UserApiRepository] Failed to fetch designations: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to fetch designations');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// Get Roles Dropdown
  /// GET /api/v1/users/dropdowns/roles?org_id={org_id}
  Future<ApiResponse<List<DropdownItem>>> getRolesDropdown(String orgId) async {
    try {
      print('📋 [UserApiRepository] Fetching roles dropdown for org: $orgId');
      await _addAuthHeader();

      final response = await _dio.get(
        '${ApiConstants.users}/dropdowns/roles',
        queryParameters: {'org_id': orgId},
      );

      if (response.statusCode == 200) {
        final dropdownResponse = RolesDropdownResponse.fromJson(response.data);
        print('✅ [UserApiRepository] Fetched ${dropdownResponse.roles.length} roles');
        return ApiResponse.success(
          message: 'Roles fetched successfully',
          data: dropdownResponse.roles,
        );
      } else {
        print('❌ [UserApiRepository] Failed to fetch roles: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to fetch roles');
      }
    } on DioException catch (e) {
      print('🚨 [UserApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Network error',
      );
    } catch (e) {
      print('🚨 [UserApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }
}
