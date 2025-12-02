import 'package:flutter/foundation.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/activity/data/user_login_history_repository.dart';
import 'package:ppv_components/features/activity/model/user_login_history.dart';

class UserLoginHistoryService extends ChangeNotifier {
  final UserLoginHistoryRepository _repository;

  UserLoginHistoryService({UserLoginHistoryRepository? repository})
      : _repository = repository ?? UserLoginHistoryRepository();

  List<UserLoginHistory> _histories = [];
  bool _isLoading = false;
  String? _error;

  List<UserLoginHistory> get histories => _histories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _histories.isNotEmpty;

  Future<({bool success, String? message})> loadHistories({bool forceRefresh = true}) async {
    if (_isLoading) {
      return (success: true, message: 'Already loading');
    }

    if (!forceRefresh && _histories.isNotEmpty) {
      return (success: true, message: 'Already loaded');
    }

    _setLoading(true);
    _setError(null);

    try {
      final userLabel = await JwtTokenManager.getName();
      final ApiResponse<UserLoginHistoryResponse> response =
          await _repository.fetchLoginHistory(userLabel: userLabel);

      if (response.success && response.data != null) {
        _histories = response.data!.histories;
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        _histories = [];
        _setLoading(false);
        _setError(response.message);
        return (success: false, message: response.message);
      }
    } catch (e) {
      _histories = [];
      _setLoading(false);
      final message = 'Failed to load login histories: $e';
      _setError(message);
      return (success: false, message: message);
    }
  }

  void clear() {
    _histories = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    if (value != null) {
      notifyListeners();
    }
  }
}
