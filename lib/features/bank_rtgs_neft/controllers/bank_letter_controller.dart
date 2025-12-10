import 'package:flutter/material.dart';

class BankLetterController {
  Future<bool> createTransferLetter({
    required String transferId,
    required String bankName,
    required String branchName,
    required String bankAddress,
    required String subject,
    required String content,
    required String saveAsStatus,
    String? createdById,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error creating transfer letter: $e');
      return false;
    }
  }

  Future<bool> createGeneralLetter({
    required String bankName,
    required String branchName,
    required String bankAddress,
    required String subject,
    required String content,
    required String saveAsStatus,
    String? createdById,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error creating general letter: $e');
      return false;
    }
  }

  Future<bool> createPaymentLetter({
    required String paymentReference,
    required String bankName,
    required String branchName,
    required String bankAddress,
    required String subject,
    required String content,
    required String saveAsStatus,
    String? createdById,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      return true;
    } catch (e) {
      debugPrint('Error creating payment letter: $e');
      return false;
    }
  }

  String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}
