import 'package:dio/dio.dart';
import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/vendor/data/models/vendor_api_models.dart';

/// Repository for Vendor API operations
/// Implements all 15+ vendor endpoints with proper error handling
class VendorApiRepository {
  final Dio _dio;

  VendorApiRepository()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConstants.vendorBaseUrl,
          connectTimeout: ApiConstants.connectionTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ));

  /// Add authorization header to requests
  Future<void> _addAuthHeader() async {
    final token = await JwtTokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  // ============ VENDOR CRUD OPERATIONS ============

  /// 1. CREATE VENDOR
  /// POST /vendors
  Future<ApiResponse<VendorApiModel>> createVendor(
      CreateVendorRequest request) async {
    try {
      print('🏢 [VendorApiRepository] Creating vendor: ${request.vendor.name}');
      print('📍 [VendorApiRepository] Endpoint: ${ApiConstants.vendorBaseUrl}${ApiConstants.vendors}');
      await _addAuthHeader();

      final requestData = request.toJson();
      print('📦 [VendorApiRepository] Request payload: $requestData');

      final response = await _dio.post(
        ApiConstants.vendors,
        data: requestData,
      );

      print('📡 [VendorApiRepository] Response status: ${response.statusCode}');
      print('📡 [VendorApiRepository] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [VendorApiRepository] Vendor created successfully');
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor created successfully',
          data: vendorResponse.vendor,
        );
      } else {
        print('⚠️ [VendorApiRepository] Unexpected status code: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to create vendor');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      print('🚨 [VendorApiRepository] Response status: ${e.response?.statusCode}');
      print('🚨 [VendorApiRepository] Response data: ${e.response?.data}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error: ${e.message}');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 2. GET VENDOR BY ID
  /// GET /vendors/{id}
  Future<ApiResponse<VendorApiModel>> getVendorById(int id) async {
    try {
      print('🔍 [VendorApiRepository] Getting vendor by ID: $id');
      await _addAuthHeader();

      final response = await _dio.get('${ApiConstants.vendors}/$id');

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor retrieved successfully');
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor retrieved successfully',
          data: vendorResponse.vendor,
        );
      } else {
        return ApiResponse.error(message: 'Vendor not found');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      if (e.response?.statusCode == 404) {
        return ApiResponse.error(message: 'Vendor not found');
      }
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 3. GET VENDOR BY CODE
  /// GET /vendors/code/{code}
  Future<ApiResponse<VendorApiModel>> getVendorByCode(String code) async {
    try {
      print('🔍 [VendorApiRepository] Getting vendor by code: $code');
      await _addAuthHeader();

      final response = await _dio.get('${ApiConstants.vendors}/code/$code');

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor retrieved successfully');
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor retrieved successfully',
          data: vendorResponse.vendor,
        );
      } else {
        return ApiResponse.error(message: 'Vendor not found');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 4. LIST VENDORS
  /// GET /vendors?page=1&per_page=10&status=ACTIVE&search=query&vendor_type=SUPPLIER
  Future<ApiResponse<VendorsListResponse>> listVendors({
    int page = 1,
    int perPage = 10,
    String? status,
    String? search,
    String? vendorType,
  }) async {
    try {
      print('📋 [VendorApiRepository] Listing vendors - Page: $page');
      await _addAuthHeader();

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (status != null && status.isNotEmpty) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
        if (vendorType != null && vendorType.isNotEmpty)
          'vendor_type': vendorType,
      };

      final response = await _dio.get(
        ApiConstants.vendors,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendors retrieved successfully');
        final vendorsResponse = VendorsListResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendors retrieved successfully',
          data: vendorsResponse,
        );
      } else {
        return ApiResponse.error(message: 'Failed to retrieve vendors');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 5. UPDATE VENDOR
  /// PUT /vendors/{id}
  Future<ApiResponse<VendorApiModel>> updateVendor(
      UpdateVendorRequest request) async {
    try {
      print('📝 [VendorApiRepository] Updating vendor: ${request.id}');
      await _addAuthHeader();

      final response = await _dio.put(
        '${ApiConstants.vendors}/${request.id}',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor updated successfully');
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor updated successfully',
          data: vendorResponse.vendor,
        );
      } else {
        return ApiResponse.error(message: 'Failed to update vendor');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 6. DELETE VENDOR
  /// DELETE /vendors/{id}
  Future<ApiResponse<DeleteResponse>> deleteVendor(int id) async {
    try {
      print('🗑️ [VendorApiRepository] Deleting vendor: $id');
      await _addAuthHeader();

      final response = await _dio.delete('${ApiConstants.vendors}/$id');

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor deleted successfully');
        final deleteResponse = DeleteResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor deleted successfully',
          data: deleteResponse,
        );
      } else {
        return ApiResponse.error(message: 'Failed to delete vendor');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============ VENDOR CODE OPERATIONS ============

  /// 7. GENERATE VENDOR CODE
  /// POST /vendors/generate-code
  Future<ApiResponse<String>> generateVendorCode({
    required String prefix,
    required String vendorName,
  }) async {
    try {
      print(
          '🔢 [VendorApiRepository] Generating vendor code - prefix: $prefix, name: $vendorName');
      await _addAuthHeader();

      final request = GenerateVendorCodeRequest(
        prefix: prefix,
        vendorName: vendorName,
      );
      final response = await _dio.post(
        '${ApiConstants.vendors}/generate-code',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor code generated successfully');
        final codeResponse = VendorCodeResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor code generated successfully',
          data: codeResponse.vendorCode,
        );
      } else {
        return ApiResponse.error(message: 'Failed to generate vendor code');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 8. UPDATE VENDOR CODE
  /// PUT /vendors/{id}/code
  Future<ApiResponse<VendorApiModel>> updateVendorCode(
      UpdateVendorCodeRequest request) async {
    try {
      print('🔢 [VendorApiRepository] Updating vendor code: ${request.id}');
      await _addAuthHeader();

      final response = await _dio.put(
        '${ApiConstants.vendors}/${request.id}/code',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor code updated successfully');
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor code updated successfully',
          data: vendorResponse.vendor,
        );
      } else {
        return ApiResponse.error(message: 'Failed to update vendor code');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 9. REGENERATE VENDOR CODE
  /// POST /vendors/{id}/regenerate-code
  Future<ApiResponse<VendorApiModel>> regenerateVendorCode(
      RegenerateVendorCodeRequest request) async {
    try {
      print('🔄 [VendorApiRepository] Regenerating vendor code: ${request.id}');
      await _addAuthHeader();

      final response = await _dio.post(
        '${ApiConstants.vendors}/${request.id}/regenerate-code',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor code regenerated successfully');
        final vendorResponse = VendorResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor code regenerated successfully',
          data: vendorResponse.vendor,
        );
      } else {
        return ApiResponse.error(message: 'Failed to regenerate vendor code');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============ VENDOR BANK ACCOUNT OPERATIONS ============

  /// 10. CREATE VENDOR ACCOUNT
  /// POST /vendors/{id}/accounts
  Future<ApiResponse<VendorBankAccount>> createVendorAccount(
      CreateVendorAccountRequest request) async {
    try {
      print('🏦 [VendorApiRepository] Creating vendor account for vendor: ${request.vendorId}');
      await _addAuthHeader();

      final response = await _dio.post(
        '${ApiConstants.vendors}/${request.vendorId}/accounts',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [VendorApiRepository] Vendor account created successfully');
        final accountResponse = VendorAccountResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor account created successfully',
          data: accountResponse.account,
        );
      } else {
        return ApiResponse.error(message: 'Failed to create vendor account');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 11. GET VENDOR ACCOUNTS
  /// GET /vendors/{id}/accounts
  Future<ApiResponse<List<VendorBankAccount>>> getVendorAccounts(
      int vendorId) async {
    try {
      print('🏦 [VendorApiRepository] Getting accounts for vendor: $vendorId');
      await _addAuthHeader();

      final response =
          await _dio.get('${ApiConstants.vendors}/$vendorId/accounts');

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor accounts retrieved successfully');
        final accountsResponse =
            VendorAccountsListResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor accounts retrieved successfully',
          data: accountsResponse.accounts,
        );
      } else {
        return ApiResponse.error(message: 'Failed to retrieve vendor accounts');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 12. GET VENDOR BANKING DETAILS
  /// GET /vendors/{id}/banking-details
  Future<ApiResponse<VendorBankingDetailsResponse>> getVendorBankingDetails(
      int vendorId) async {
    try {
      print('🏦 [VendorApiRepository] Getting banking details for vendor: $vendorId');
      await _addAuthHeader();

      final response =
          await _dio.get('${ApiConstants.vendors}/$vendorId/banking-details');

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Banking details retrieved successfully');
        final bankingResponse =
            VendorBankingDetailsResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Banking details retrieved successfully',
          data: bankingResponse,
        );
      } else {
        return ApiResponse.error(
            message: 'Failed to retrieve banking details');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 13. UPDATE VENDOR ACCOUNT
  /// PUT /vendors/accounts/{id}
  Future<ApiResponse<VendorBankAccount>> updateVendorAccount(
      UpdateVendorAccountRequest request) async {
    try {
      print('📝 [VendorApiRepository] Updating vendor account: ${request.id}');
      await _addAuthHeader();

      final response = await _dio.put(
        '${ApiConstants.vendors}/accounts/${request.id}',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor account updated successfully');
        final accountResponse = VendorAccountResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor account updated successfully',
          data: accountResponse.account,
        );
      } else {
        return ApiResponse.error(message: 'Failed to update vendor account');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 14. DELETE VENDOR ACCOUNT
  /// DELETE /vendors/accounts/{id}
  Future<ApiResponse<DeleteResponse>> deleteVendorAccount(int id) async {
    try {
      print('🗑️ [VendorApiRepository] Deleting vendor account: $id');
      await _addAuthHeader();

      final response =
          await _dio.delete('${ApiConstants.vendors}/accounts/$id');

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Vendor account deleted successfully');
        final deleteResponse = DeleteResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Vendor account deleted successfully',
          data: deleteResponse,
        );
      } else {
        return ApiResponse.error(message: 'Failed to delete vendor account');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  /// 15. TOGGLE ACCOUNT STATUS
  /// POST /vendors/accounts/{id}/toggle-status
  Future<ApiResponse<VendorBankAccount>> toggleAccountStatus(
      ToggleAccountStatusRequest request) async {
    try {
      print('🔄 [VendorApiRepository] Toggling account status: ${request.id}');
      await _addAuthHeader();

      final response = await _dio.post(
        '${ApiConstants.vendors}/accounts/${request.id}/toggle-status',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        print('✅ [VendorApiRepository] Account status toggled successfully');
        final accountResponse = VendorAccountResponse.fromJson(response.data);
        return ApiResponse.success(
          message: 'Account status toggled successfully',
          data: accountResponse.account,
        );
      } else {
        return ApiResponse.error(message: 'Failed to toggle account status');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  // ============ DROPDOWN SUPPORT ============ 

  /// Get project dropdown values
  /// GET /vendors/dropdowns/projects
  Future<ApiResponse<List<String>>> getProjectDropdowns() async {
    try {
      print('📁 [VendorApiRepository] Loading project dropdowns');
      await _addAuthHeader();

      final response =
          await _dio.get('${ApiConstants.vendors}/dropdowns/projects');

      if (response.statusCode == 200) {
        final projects = _extractProjectNames(response.data);
        print(
            '✅ [VendorApiRepository] Received ${projects.length} projects for dropdown');
        return ApiResponse.success(
          message: 'Projects loaded successfully',
          data: projects,
        );
      } else {
        print(
            '❌ [VendorApiRepository] Failed to load projects: ${response.statusCode}');
        return ApiResponse.error(message: 'Failed to load projects');
      }
    } on DioException catch (e) {
      print('🚨 [VendorApiRepository] DioException: ${e.message}');
      return ApiResponse.error(
          message: e.response?.data['message'] ?? 'Network error');
    } catch (e) {
      print('🚨 [VendorApiRepository] Exception: $e');
      return ApiResponse.error(message: 'Unexpected error: $e');
    }
  }

  List<String> _extractProjectNames(dynamic payload) {
    final List<String> projects = [];

    List<dynamic>? rawList;

    if (payload is List<dynamic>) {
      rawList = payload;
    } else if (payload is Map<String, dynamic>) {
      if (payload['projects'] is List<dynamic>) {
        rawList = payload['projects'] as List<dynamic>;
      } else if (payload['data'] is List<dynamic>) {
        rawList = payload['data'] as List<dynamic>;
      } else if (payload['items'] is List<dynamic>) {
        rawList = payload['items'] as List<dynamic>;
      }
    }

    rawList ??= [];

    for (final item in rawList) {
      if (item is String) {
        if (item.trim().isNotEmpty) {
          projects.add(item.trim());
        }
      } else if (item is Map<String, dynamic>) {
        final name = item['projectName'] ??
            item['project_name'] ??
            item['name'] ??
            item['title'];
        if (name is String && name.trim().isNotEmpty) {
          projects.add(name.trim());
        }
      }
    }

    return projects.toSet().toList()..sort();
  }
}
