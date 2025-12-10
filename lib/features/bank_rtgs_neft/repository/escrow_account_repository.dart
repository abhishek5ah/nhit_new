import '../services/api_client.dart';
import '../models/escrow_account_request.dart';
import '../models/escrow_account_response.dart';

class EscrowAccountRepository {
  final ApiClient _apiClient = ApiClient();

  // Create escrow account
  Future<EscrowAccountResponse> createEscrowAccount(CreateEscrowAccountRequest request) async {
    try {
      final response = await _apiClient.post(
        '/escrow/accounts',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EscrowAccountResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to create escrow account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating escrow account: ${e.toString()}');
    }
  }

  // Get escrow account by ID
  Future<EscrowAccountResponse> getEscrowAccount(String accountId) async {
    try {
      final response = await _apiClient.get('/escrow/accounts/$accountId');

      if (response.statusCode == 200) {
        return EscrowAccountResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to get escrow account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching escrow account: ${e.toString()}');
    }
  }

  // Update escrow account
  Future<EscrowAccountResponse> updateEscrowAccount(UpdateEscrowAccountRequest request) async {
    try {
      final response = await _apiClient.put(
        '/escrow/accounts/${request.accountId}',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return EscrowAccountResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to update escrow account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating escrow account: ${e.toString()}');
    }
  }

  // Delete escrow account
  Future<void> deleteEscrowAccount(String accountId) async {
    try {
      final response = await _apiClient.delete('/escrow/accounts/$accountId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete escrow account: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting escrow account: ${e.toString()}');
    }
  }

  // List escrow accounts
  Future<List<EscrowAccountData>> listEscrowAccounts({
    int page = 1,
    int pageSize = 10,
    String? searchQuery,
    String? statusFilter,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search_query'] = searchQuery;
      }

      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryParams['status_filter'] = statusFilter;
      }

      final response = await _apiClient.get(
        '/escrow/accounts',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final accounts = data['accounts'] as List;
        return accounts.map((account) => EscrowAccountData.fromJson(account)).toList();
      } else {
        throw Exception('Failed to list escrow accounts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error listing escrow accounts: ${e.toString()}');
    }
  }

  // Get escrow account stats
  Future<Map<String, dynamic>> getEscrowAccountStats() async {
    try {
      final response = await _apiClient.get('/escrow/accounts/stats');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get escrow account stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching escrow account stats: ${e.toString()}');
    }
  }
}
