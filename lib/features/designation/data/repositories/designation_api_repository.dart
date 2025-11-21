import 'package:dio/dio.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/features/designation/model/designation_model.dart';

/// Response wrapper for designations list
class DesignationsResponse {
  final List<Designation> designations;
  final dynamic pagination;

  DesignationsResponse({
    required this.designations,
    this.pagination,
  });

  factory DesignationsResponse.fromJson(Map<String, dynamic> json) {
    return DesignationsResponse(
      designations: (json['designations'] as List<dynamic>?)
              ?.map((e) => Designation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'],
    );
  }
}

/// Response wrapper for single designation
class DesignationResponse {
  final Designation designation;
  final String? message;

  DesignationResponse({
    required this.designation,
    this.message,
  });

  factory DesignationResponse.fromJson(Map<String, dynamic> json) {
    return DesignationResponse(
      designation: Designation.fromJson(json['designation']),
      message: json['message'],
    );
  }
}

/// Repository for Designation Management API calls
/// Base URL: http://192.168.1.51:8083/api/v1
class DesignationApiRepository {
  final Dio _dio;

  DesignationApiRepository({Dio? dio}) : _dio = dio ?? Dio() {
    // Only configure Dio when we create it ourselves
    if (dio == null) {
      _dio.options = BaseOptions(
        baseUrl: ApiConstants.designationBaseUrl,
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
        logPrint: (obj) => print('🌐 [DesignationAPI] $obj'),
      ));
    }
  }

  /// GET /api/v1/designations - Get all designations
  Future<({bool success, String? message, DesignationsResponse? data})>
      getDesignations() async {
    try {
      print('🔍 [DesignationApiRepository] GET /designations');
      final response = await _dio.get('/designations');

      print('📥 [DesignationApiRepository] Response: ${response.statusCode}');
      print('📦 [DesignationApiRepository] Data: ${response.data}');

      final designationsResponse = DesignationsResponse.fromJson(response.data);

      return (
        success: true,
        message: 'Designations loaded successfully',
        data: designationsResponse,
      );
    } on DioException catch (e) {
      print('🚨 [DesignationApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to load designations';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DesignationApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// GET /api/v1/designations/:id - Get designation by ID
  Future<({bool success, String? message, Designation? data})>
      getDesignationById(String id) async {
    try {
      print('🔍 [DesignationApiRepository] GET /designations/$id');
      final response = await _dio.get('/designations/$id');

      print('📥 [DesignationApiRepository] Response: ${response.statusCode}');

      final designationResponse = DesignationResponse.fromJson(response.data);

      return (
        success: true,
        message: designationResponse.message ?? 'Designation loaded successfully',
        data: designationResponse.designation,
      );
    } on DioException catch (e) {
      print('🚨 [DesignationApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to load designation';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DesignationApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// POST /api/v1/designations - Create new designation
  Future<({bool success, String? message, Designation? data})>
      createDesignation({
    required String name,
    required String description,
  }) async {
    try {
      print('📝 [DesignationApiRepository] POST /designations');
      final requestData = {
        'name': name,
        'description': description,
      };
      print('📦 [DesignationApiRepository] Request: $requestData');

      final response = await _dio.post(
        '/designations',
        data: requestData,
      );

      print('📥 [DesignationApiRepository] Response: ${response.statusCode}');
      print('📦 [DesignationApiRepository] Data: ${response.data}');

      final designationResponse = DesignationResponse.fromJson(response.data);

      return (
        success: true,
        message: designationResponse.message ?? 'Designation created successfully',
        data: designationResponse.designation,
      );
    } on DioException catch (e) {
      print('🚨 [DesignationApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to create designation';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DesignationApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// PUT /api/v1/designations/:id - Update designation
  Future<({bool success, String? message, Designation? data})>
      updateDesignation({
    required String id,
    required String name,
    required String description,
  }) async {
    try {
      print('📝 [DesignationApiRepository] PUT /designations/$id');
      final requestData = {
        'name': name,
        'description': description,
      };
      print('📦 [DesignationApiRepository] Request: $requestData');

      final response = await _dio.put(
        '/designations/$id',
        data: requestData,
      );

      print('📥 [DesignationApiRepository] Response: ${response.statusCode}');

      final designationResponse = DesignationResponse.fromJson(response.data);

      return (
        success: true,
        message: designationResponse.message ?? 'Designation updated successfully',
        data: designationResponse.designation,
      );
    } on DioException catch (e) {
      print('🚨 [DesignationApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to update designation';
      return (
        success: false,
        message: errorMessage,
        data: null,
      );
    } catch (e) {
      print('🚨 [DesignationApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  /// DELETE /api/v1/designations/:id - Delete designation
  Future<({bool success, String? message})> deleteDesignation(
      String id) async {
    try {
      print('🗑️ [DesignationApiRepository] DELETE /designations/$id');

      final response = await _dio.delete('/designations/$id');

      print('📥 [DesignationApiRepository] Response: ${response.statusCode}');

      final message = response.data?['message']?.toString() ?? 
          'Designation deleted successfully';

      return (
        success: true,
        message: message,
      );
    } on DioException catch (e) {
      print('🚨 [DesignationApiRepository] Error: ${e.message}');
      final errorMessage = e.response?.data?['message']?.toString() ??
          'Failed to delete designation';
      return (
        success: false,
        message: errorMessage,
      );
    } catch (e) {
      print('🚨 [DesignationApiRepository] Unexpected error: $e');
      return (
        success: false,
        message: 'Unexpected error: $e',
      );
    }
  }
}
