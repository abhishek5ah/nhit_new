import 'package:dio/dio.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';

/// Abstraction for Role Management data access (for easier testing)
abstract class IRolesApiRepository {
  Future<({bool success, String? message, RolesListResponse? data})> getRoles();

  Future<({bool success, String? message, RoleModel? data})> getRoleById(
    String roleId,
  );

  Future<({bool success, String? message, RoleModel? data})> createRole(
    CreateRoleRequest request,
  );

  Future<({bool success, String? message, RoleModel? data})> updateRole(
    String roleId,
    UpdateRoleRequest request,
  );

  Future<({bool success, String? message})> deleteRole(String roleId);

  Future<({bool success, String? message, List<PermissionModel>? data})>
      getPermissions();
}

/// Repository for Role Management API calls
/// Base URL: http://192.168.1.51:8083/api/v1
class RolesApiRepository implements IRolesApiRepository {
  final Dio _dio;

  RolesApiRepository({Dio? dio}) : _dio = dio ?? Dio() {
    // Only configure Dio when we create it ourselves.
    if (dio == null) {
      _dio.options = BaseOptions(
        baseUrl: ApiConstants.authBaseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      _dio.interceptors.add(AuthInterceptor());
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🌐 [RolesAPI] $obj'),
      ));
    }
  }

  /// GET /api/v1/roles - Get all roles
  Future<({bool success, String? message, RolesListResponse? data})> getRoles() async {
    try {
      print('🔍 [RolesApiRepository] GET /roles');
      final response = await _dio.get('/roles');
      
      print('📥 [RolesApiRepository] Response: ${response.statusCode}');
      print('📦 [RolesApiRepository] Data: ${response.data}');
      
      final rolesResponse = RolesListResponse.fromJson(response.data);
      
      return (
        success: true,
        message: 'Roles loaded successfully',
        data: rolesResponse,
      );
    } on DioException catch (e) {
      print('🚨 [RolesApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to load roles';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [RolesApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// GET /api/v1/roles/{role_id} - Get role by ID
  Future<({bool success, String? message, RoleModel? data})> getRoleById(String roleId) async {
    try {
      print('🔍 [RolesApiRepository] GET /roles/$roleId');
      final response = await _dio.get('/roles/$roleId');
      
      print('📥 [RolesApiRepository] Response: ${response.statusCode}');
      
      final role = RoleModel.fromJson(response.data);
      
      return (
        success: true,
        message: 'Role loaded successfully',
        data: role,
      );
    } on DioException catch (e) {
      print('🚨 [RolesApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to load role';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [RolesApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// POST /api/v1/roles - Create new role
  Future<({bool success, String? message, RoleModel? data})> createRole(CreateRoleRequest request) async {
    try {
      print('📝 [RolesApiRepository] POST /roles');
      print('📦 [RolesApiRepository] Request: ${request.toJson()}');
      
      final response = await _dio.post(
        '/roles',
        data: request.toJson(),
      );
      
      print('📥 [RolesApiRepository] Response: ${response.statusCode}');
      print('📦 [RolesApiRepository] Data: ${response.data}');
      
      final role = RoleModel.fromJson(response.data);
      
      return (
        success: true,
        message: 'Role created successfully',
        data: role,
      );
    } on DioException catch (e) {
      print('🚨 [RolesApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to create role';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [RolesApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// PUT /api/v1/roles/{role_id} - Update role
  Future<({bool success, String? message, RoleModel? data})> updateRole(
    String roleId,
    UpdateRoleRequest request,
  ) async {
    try {
      print('📝 [RolesApiRepository] PUT /roles/$roleId');
      print('📦 [RolesApiRepository] Request: ${request.toJson()}');
      
      final response = await _dio.put(
        '/roles/$roleId',
        data: request.toJson(),
      );
      
      print('📥 [RolesApiRepository] Response: ${response.statusCode}');
      
      final role = RoleModel.fromJson(response.data);
      
      return (
        success: true,
        message: 'Role updated successfully',
        data: role,
      );
    } on DioException catch (e) {
      print('🚨 [RolesApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to update role';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [RolesApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// DELETE /api/v1/roles/{role_id} - Delete role
  Future<({bool success, String? message})> deleteRole(String roleId) async {
    try {
      print('🗑️ [RolesApiRepository] DELETE /roles/$roleId');
      
      final response = await _dio.delete('/roles/$roleId');
      
      print('📥 [RolesApiRepository] Response: ${response.statusCode}');
      
      return (
        success: true,
        message: 'Role deleted successfully',
      );
    } on DioException catch (e) {
      print('🚨 [RolesApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to delete role';
      return (
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      print('🚨 [RolesApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }

  /// GET /api/v1/permissions - Get all available permissions
  Future<({bool success, String? message, List<PermissionModel>? data})> getPermissions() async {
    try {
      print('🔍 [RolesApiRepository] GET /permissions');
      final response = await _dio.get('/permissions');
      
      print('📥 [RolesApiRepository] Response: ${response.statusCode}');
      
      final permissionsResponse = PermissionsResponse.fromJson(response.data);
      
      return (
        success: true,
        message: 'Permissions loaded successfully',
        data: permissionsResponse.permissions,
      );
    } on DioException catch (e) {
      print('🚨 [RolesApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ?? 'Failed to load permissions';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [RolesApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }
}
