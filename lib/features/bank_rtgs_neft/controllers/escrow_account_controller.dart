import 'package:flutter/material.dart';
import '../services/escrow_account_service.dart';
import '../models/escrow_account_response.dart';

class EscrowAccountController {
  final EscrowAccountService _service = EscrowAccountService();

  // Create escrow account
  Future<bool> createEscrowAccount({
    required String accountName,
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
      await _service.createEscrowAccount(
        account_name: accountName,
        accountNumber: accountNumber,
        bankName: bankName,
        branchName: branchName,
        ifscCode: ifscCode,
        accountType: accountType,
        balance: balance,
        description: description,
        authorizedSignatories: authorizedSignatories,
        createdById: createdById,
      );
      return true;
    } catch (e) {
      debugPrint('Error creating escrow account: $e');
      return false;
    }
  }

  // Get escrow account for update mode
  Future<EscrowAccountData?> getEscrowAccount(String accountId) async {
    try {
      return await _service.getEscrowAccount(accountId);
    } catch (e) {
      debugPrint('Error fetching escrow account: $e');
      return null;
    }
  }

  // Update escrow account
  Future<bool> updateEscrowAccount({
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
      await _service.updateEscrowAccount(
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
      return true;
    } catch (e) {
      debugPrint('Error updating escrow account: $e');
      return false;
    }
  }

  // Get error message from exception
  String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}
