import 'package:ppv_components/core/constants/api_constants.dart';
import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';

class ActivityLogsRepository {
  Future<ApiResponse<ActivityLogsResponse>> fetchActivityLogs({
    required int page,
    required int pageSize,
  }) {
    return ApiService.get<ActivityLogsResponse>(
      ApiConstants.activityLogs,
      queryParameters: {
        'page.page': page,
        'page.page_size': pageSize,
      },
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          final payload = data.containsKey('data') && data['data'] is Map<String, dynamic>
              ? data['data'] as Map<String, dynamic>
              : data;
          return ActivityLogsResponse.fromJson(payload);
        }
        throw Exception('Unexpected activity logs response format: $data');
      },
    );
  }
}
