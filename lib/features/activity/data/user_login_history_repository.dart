import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';

class UserLoginHistoryRepository {
  Future<ApiResponse<UserLoginHistoryResponse>> fetchLoginHistory({
    String? userLabel,
  }) {
    print('🧾 [UserLoginHistoryRepository] GET ${ApiConstants.userLoginHistory}');
    return ApiService.get<UserLoginHistoryResponse>(
      ApiConstants.userLoginHistory,
      fromJson: (response) {
        if (response is Map<String, dynamic>) {
          return UserLoginHistoryResponse.fromJson(
            response,
            userLabel: userLabel,
          );
        }
        throw Exception('Unexpected login history response format: $response');
      },
    );
  }
}
