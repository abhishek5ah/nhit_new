import '../models/bank_models/create_bank_letter_request.dart';
import '../repository/bank_letter_repository.dart';

class BankLetterService {
  final BankLetterRepository _repository = BankLetterRepository();

  Future<Map<String, dynamic>> createTransferLetter({
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
      final request = CreateBankLetterRequest(
        letterType: 'TRANSFER_LETTER',
        createdById: createdById ?? '123e4567-e89b-12d3-a456-426614174000',
        bankName: bankName,
        branchName: branchName,
        bankAddress: bankAddress,
        subject: subject,
        content: content,
        attachments: const [],
        transferId: transferId,
        paymentSlNo: null,
        saveAsStatus: saveAsStatus,
      );

      return await _repository.createBankLetter(request);
    } catch (e) {
      throw Exception('Failed to create transfer letter: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createGeneralLetter({
    required String bankName,
    required String branchName,
    required String bankAddress,
    required String subject,
    required String content,
    required String saveAsStatus,
    String? createdById,
  }) async {
    try {
      final request = CreateBankLetterRequest(
        letterType: 'GENERAL_LETTER',
        createdById: createdById ?? '123e4567-e89b-12d3-a456-426614174000',
        bankName: bankName,
        branchName: branchName,
        bankAddress: bankAddress,
        subject: subject,
        content: content,
        attachments: const [],
        transferId: null,
        paymentSlNo: null,
        saveAsStatus: saveAsStatus,
      );

      return await _repository.createBankLetter(request);
    } catch (e) {
      throw Exception('Failed to create general letter: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> createPaymentLetter({
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
      final request = CreateBankLetterRequest(
        letterType: 'PAYMENT_LETTER',
        createdById: createdById ?? '123e4567-e89b-12d3-a456-426614174000',
        bankName: bankName,
        branchName: branchName,
        bankAddress: bankAddress,
        subject: subject,
        content: content,
        attachments: const [],
        transferId: null,
        paymentSlNo: paymentReference,
        saveAsStatus: saveAsStatus,
      );

      return await _repository.createBankLetter(request);
    } catch (e) {
      throw Exception('Failed to create payment letter: ${e.toString()}');
    }
  }
}
