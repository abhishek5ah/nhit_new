import '../repository/escrow_account_repository.dart';
import '../models/escrow_account_request.dart';
import '../models/escrow_account_response.dart';

class EscrowAccountService {
  final EscrowAccountRepository _repository = EscrowAccountRepository();

  // Create escrow account
  Future<EscrowAccountData> createEscrowAccount({
    required String account_name,
    required String accountNumber,
    required String bankName,
    required String branchName,
    required String ifscCode,
    required String accountType,
    required double balance,
    required String description,
    required List<String> authorizedSignatories,
    String? createdById,
  }) async {
    try {
      final request = CreateEscrowAccountRequest(
        accountName: account_name,
        accountNumber: accountNumber,
        bankName: bankName,
        branchName: branchName,
        ifscCode: ifscCode,
        accountType: accountType,
        balance: balance,
        description: description,
        authorizedSignatories: authorizedSignatories,
        createdById: createdById ?? '550e8400-e29b-41d4-a716-446655440101', // Provide default if null
      );

      final response = await _repository.createEscrowAccount(request);
      return response.account;
    } catch (e) {
      throw Exception('Failed to create escrow account: ${e.toString()}');
    }
  }

  // Get escrow account by ID
  Future<EscrowAccountData> getEscrowAccount(String accountId) async {
    try {
      final response = await _repository.getEscrowAccount(accountId);
      return response.account;
    } catch (e) {
      throw Exception('Failed to get escrow account: ${e.toString()}');
    }
  }

  // Update escrow account
  Future<EscrowAccountData> updateEscrowAccount({
    required String accountId,
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String branchName,
    required String ifscCode,
    required String accountType,
    required String description,
    required List<String> authorizedSignatories,
    String status = 'active',
  }) async {
    try {
      final request = UpdateEscrowAccountRequest(
        accountId: accountId,
        accountName: accountName,
        accountNumber: accountNumber,
        bankName: bankName,
        branchName: branchName,
        ifscCode: ifscCode,
        accountType: accountType,
        description: description,
        authorizedSignatories: authorizedSignatories,
        status: status,
      );

      final response = await _repository.updateEscrowAccount(request);
      return response.account;
    } catch (e) {
      throw Exception('Failed to update escrow account: ${e.toString()}');
    }
  }

  // Delete escrow account
  Future<void> deleteEscrowAccount(String accountId) async {
    try {
      await _repository.deleteEscrowAccount(accountId);
    } catch (e) {
      throw Exception('Failed to delete escrow account: ${e.toString()}');
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
      return await _repository.listEscrowAccounts(
        page: page,
        pageSize: pageSize,
        searchQuery: searchQuery,
        statusFilter: statusFilter,
      );
    } catch (e) {
      throw Exception('Failed to list escrow accounts: ${e.toString()}');
    }
  }

  // Get escrow account stats
  Future<Map<String, dynamic>> getEscrowAccountStats() async {
    try {
      return await _repository.getEscrowAccountStats();
    } catch (e) {
      throw Exception('Failed to get escrow account stats: ${e.toString()}');
    }
  }

  // Convert EscrowAccountData to EscrowAccount for UI compatibility
  List<EscrowAccount> convertToEscrowAccounts(List<EscrowAccountData> accounts) {
    return accounts.map((account) => account.toEscrowAccount()).toList();
  }
}
