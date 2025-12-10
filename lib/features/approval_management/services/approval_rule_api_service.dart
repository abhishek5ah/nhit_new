import 'package:ppv_components/core/services/api_service.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/approval_management/models/approval_rule_api_models.dart';

class ApprovalRuleApiService {
  static const String rulePath = '/approval/rules';

  /// Create a new approval rule
  Future<ApiResponse<RuleResponse>> createApprovalRule(
    CreateApprovalRuleRequest request,
  ) async {
    try {
      final response = await ApiService.post<RuleResponse>(
        rulePath,
        data: request.toJson(),
        fromJson: (json) => RuleResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<RuleResponse>.error(
        message: 'Failed to create approval rule: $e',
      );
    }
  }

  /// Get all approval rules
  Future<ApiResponse<List<RuleResponse>>> getApprovalRules() async {
    try {
      final response = await ApiService.get<List<RuleResponse>>(
        rulePath,
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => RuleResponse.fromJson(item))
                .toList();
          }
          return <RuleResponse>[];
        },
      );

      return response;
    } catch (e) {
      return ApiResponse<List<RuleResponse>>.error(
        message: 'Failed to fetch approval rules: $e',
      );
    }
  }

  /// Get a single approval rule by ID
  Future<ApiResponse<RuleResponse>> getApprovalRuleById(String id) async {
    try {
      final response = await ApiService.get<RuleResponse>(
        '$rulePath/$id',
        fromJson: (json) => RuleResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<RuleResponse>.error(
        message: 'Failed to fetch approval rule: $e',
      );
    }
  }

  /// Update an approval rule
  Future<ApiResponse<RuleResponse>> updateApprovalRule(
    String id,
    CreateApprovalRuleRequest request,
  ) async {
    try {
      final response = await ApiService.put<RuleResponse>(
        '$rulePath/$id',
        data: request.toJson(),
        fromJson: (json) => RuleResponse.fromJson(json),
      );

      return response;
    } catch (e) {
      return ApiResponse<RuleResponse>.error(
        message: 'Failed to update approval rule: $e',
      );
    }
  }

  /// Delete an approval rule
  Future<ApiResponse<void>> deleteApprovalRule(String id) async {
    try {
      final response = await ApiService.delete<void>(
        '$rulePath/$id',
      );

      return response;
    } catch (e) {
      return ApiResponse<void>.error(
        message: 'Failed to delete approval rule: $e',
      );
    }
  }
}
