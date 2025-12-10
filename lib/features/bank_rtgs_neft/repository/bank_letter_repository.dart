import '../services/api_client.dart';
import '../models/bank_models/create_bank_letter_request.dart';

class BankLetterRepository {
  final ApiClient _apiClient = ApiClient();

  BankLetterRepository() {
    // Ensure Dio client is initialized for bank letter calls
    _apiClient.initialize();
  }

  Future<Map<String, dynamic>> createBankLetter(CreateBankLetterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/letters',
        data: request.toJson(),
      );

      final statusCode = response.statusCode ?? 500;
      if (statusCode == 200 || statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return data;
        }
        return {'raw': data};
      } else {
        throw Exception('Failed to create bank letter: $statusCode');
      }
    } catch (e) {
      throw Exception('Error creating bank letter: ${e.toString()}');
    }
  }
}
