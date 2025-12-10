import 'dart:async';
import 'package:dio/dio.dart';
import '../models/transfer_models/transfer_enums.dart';
import '../models/transfer_models/transfer_model.dart';
import '../models/transfer_models/transfer_request.dart';
import 'api_client.dart';

class AccountTransferService {
  final ApiClient _apiClient = ApiClient();
  static const _maxRetries = 1;
  static const _retryDelay = Duration(seconds: 1);
  
  AccountTransferService() {
    _apiClient.initialize();
  }

  Future<Transfer> createTransfer(CreateAccountTransferRequest request) async {
    try {
      // Validate request before sending
      request.validate();

      print('🚀 Creating transfer with payload: ${request.toJson()}');

      final idempotencyKey = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await _retryWithBackoff(
        () => _apiClient.post(
          '/transfers',
          data: request.toJson(),
          options: Options(
            headers: {
              'Idempotency-Key': idempotencyKey,
              'X-Request-Source': 'create-transfer-page',
            },
          ),
        ),
        maxRetries: _maxRetries,
        delay: _retryDelay,
      );

      print('✅ Response status: ${response.statusCode}');
      print('✅ Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        print('📦 Raw response data: $data');
        
        // Handle response according to protobuf AccountTransferResponse structure
        if (data is Map<String, dynamic>) {
          // Primary format: AccountTransferResponse with 'transfer' key
          if (data.containsKey('transfer')) {
            print('✅ Parsing AccountTransferResponse (protobuf format)');
            final accountTransferResponse = AccountTransferResponse.fromJson(data);
            return accountTransferResponse.transfer;
          }
          // Alternative format: Array of transfers
          else if (data.containsKey('transfers') && data['transfers'] is List && (data['transfers'] as List).isNotEmpty) {
            print('✅ Parsing from transfers array');
            return Transfer.fromJson((data['transfers'] as List).first as Map<String, dynamic>);
          }
          // Direct transfer object
          else if (data.containsKey('transferId')) {
            print('✅ Parsing direct transfer object');
            return Transfer.fromJson(data);
          }
        }
        
        throw Exception('Invalid response format. Expected AccountTransferResponse with "transfer" key. Got: ${response.data}');
      } else {
        throw Exception('Failed to create transfer: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('❌ Error creating transfer: $e');
      if (e is ValidationException) rethrow;
      throw Exception('Error creating transfer: ${e.toString()}');
    }
  }

  Future<Transfer> getTransfer(String transferId) async {
    try {
      final response = await _apiClient.get('/transfers/$transferId');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('transfer')) {
          return Transfer.fromJson(data['transfer']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to get transfer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting transfer: ${e.toString()}');
    }
  }

  /// Cancel a transfer using POST /transfers/{transfer_id}/cancel
  /// Request body must include: transfer_id, user_id, reason
  Future<void> cancelTransfer(String transferId, String userId, String reason) async {
    try {
      print('🔄 Cancelling transfer: $transferId with user: $userId');
      print('📤 Request body: {transfer_id: $transferId, user_id: $userId, reason: $reason}');
      
      final response = await _apiClient.post(
        '/transfers/$transferId/cancel',
        data: {
          'transfer_id': transferId,
          'user_id': userId,
          'reason': reason,
        },
      );

      print('📥 Cancel response status: ${response.statusCode}');
      print('📥 Cancel response data: ${response.data}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorMsg = response.data is Map 
            ? (response.data['message'] ?? response.data['error'] ?? 'Unknown error')
            : response.data?.toString() ?? 'Unknown error';
        throw Exception('Failed to cancel transfer: $errorMsg (Status: ${response.statusCode})');
      }
    } on Exception catch (e) {
      print('❌ Cancel transfer error: $e');
      rethrow;
    } catch (e) {
      print('❌ Unexpected cancel error: $e');
      throw Exception('Error cancelling transfer: ${e.toString()}');
    }
  }

  Future<List<Transfer>> listTransfers({
    int page = 1,
    int pageSize = 10,
    String? transferType,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (transferType != null) 'transfer_type': transferType,
        if (status != null) 'status': status,
      };

      final response = await _apiClient.get(
        '/transfers',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> && data.containsKey('transfers')) {
          final transfersList = data['transfers'] as List;
          return transfersList
              .map((json) => Transfer.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to list transfers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing transfers: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getTransferStats() async {
    try {
      final response = await _apiClient.get('/transfers/stats');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {};
      } else {
        throw Exception('Failed to get transfer stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting transfer stats: ${e.toString()}');
    }
  }

  Future<T> _retryWithBackoff<T>(
    Future<T> Function() operation, {
    int maxRetries = 1,
    Duration delay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts > maxRetries || e is ValidationException) {
          rethrow;
        }
        await Future.delayed(delay * attempts);
      }
    }
  }
}
