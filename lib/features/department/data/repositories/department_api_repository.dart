import 'package:dio/dio.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/features/department/model/department_model.dart';

/// Response wrapper for departments list
class DepartmentsResponse {
  final List<Department> departments;
  final int? totalCount;

  DepartmentsResponse({
    required this.departments,
    this.totalCount,
  });

  factory DepartmentsResponse.fromJson(Map<String, dynamic> json) {
    return DepartmentsResponse(
      departments: (json['departments'] as List<dynamic>?)
              ?.map((e) => Department.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'],
    );
  }
}

/// Repository for Department Management API calls
/// Base URL: http://192.168.1.51:8083/api/v1
class DepartmentApiRepository {
  final Dio _dio;

  DepartmentApiRepository({Dio? dio}) : _dio = dio ?? Dio() {
    // Only configure Dio when we create it ourselves
    if (dio == null) {
      _dio.options = BaseOptions(
        baseUrl: ApiConstants.departmentBaseUrl,
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
        logPrint: (obj) => print('🌐 [DepartmentAPI] $obj'),
      ));
    }
  }

  /// GET /api/v1/departments - Get all departments
  Future<({bool success, String? message, DepartmentsResponse? data})>
      getDepartments() async {
    try {
      print('🔍 [DepartmentApiRepository] GET /departments');
      final response = await _dio.get('/departments');

      print('📥 [DepartmentApiRepository] Response: ${response.statusCode}');
      print('📦 [DepartmentApiRepository] Data: ${response.data}');

      final departmentsResponse = DepartmentsResponse.fromJson(response.data);

      return (
        success: true,
        message: 'Departments loaded successfully',
        data: departmentsResponse,
      );
    } on DioException catch (e) {
      print('🚨 [DepartmentApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to load departments';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DepartmentApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// POST /api/v1/departments - Create new department
  Future<({bool success, String? message, Department? data})> createDepartment({
    required String name,
    required String description,
  }) async {
    try {
      print('📝 [DepartmentApiRepository] POST /departments');
      final requestData = {
        'name': name,
        'description': description,
      };
      print('📦 [DepartmentApiRepository] Request: $requestData');

      final response = await _dio.post(
        '/departments',
        data: requestData,
      );

      print('📥 [DepartmentApiRepository] Response: ${response.statusCode}');
      print('📦 [DepartmentApiRepository] Data: ${response.data}');

      final department = Department.fromJson(response.data);

      return (
        success: true,
        message: 'Department created successfully',
        data: department,
      );
    } on DioException catch (e) {
      print('🚨 [DepartmentApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to create department';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DepartmentApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// PUT /api/v1/departments/:id - Update department
  Future<({bool success, String? message, Department? data})> updateDepartment({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      print('📝 [DepartmentApiRepository] PUT /departments/$id');
      final requestData = {
        'name': name,
        'description': description,
      };
      print('📦 [DepartmentApiRepository] Request: $requestData');

      final response = await _dio.put(
        '/departments/$id',
        data: requestData,
      );

      print('📥 [DepartmentApiRepository] Response: ${response.statusCode}');

      final department = Department.fromJson(response.data);

      return (
        success: true,
        message: 'Department updated successfully',
        data: department,
      );
    } on DioException catch (e) {
      print('🚨 [DepartmentApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to update department';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DepartmentApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// DELETE /api/v1/departments/:id - Delete department
  Future<({bool success, String? message})> deleteDepartment(
      String id) async {
    try {
      print('🗑️ [DepartmentApiRepository] DELETE /departments/$id');

      final response = await _dio.delete('/departments/$id');

      print('📥 [DepartmentApiRepository] Response: ${response.statusCode}');

      return (
        success: true,
        message: 'Department deleted successfully',
      );
    } on DioException catch (e) {
      print('🚨 [DepartmentApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to delete department';
      return (
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      print('🚨 [DepartmentApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }
}
