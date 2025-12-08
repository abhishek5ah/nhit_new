import 'package:flutter/foundation.dart';
import 'package:ppv_components/core/utils/api_response.dart';
import 'package:ppv_components/features/activity/data/activity_logs_repository.dart';
import 'package:ppv_components/features/activity/model/activity_logs_model.dart';

class ActivityLogsService extends ChangeNotifier {
  final ActivityLogsRepository _repository;

  ActivityLogsService({ActivityLogsRepository? repository})
      : _repository = repository ?? ActivityLogsRepository();

  List<ActivityLog> _logs = [];
  PaginationMeta? _pagination;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _pageSize = 10;

  List<ActivityLog> get logs => _logs;
  PaginationMeta? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasData => _logs.isNotEmpty;

  Future<({bool success, String? message})> loadLogs({
    int? page,
    int? pageSize,
    bool forceRefresh = false,
  }) async {
    final targetPage = page ?? _currentPage;
    final targetPageSize = pageSize ?? _pageSize;

    if (!forceRefresh &&
        _logs.isNotEmpty &&
        targetPage == _currentPage &&
        targetPageSize == _pageSize) {
      return (success: true, message: 'Already loaded');
    }

    _setLoading(true);
    _setError(null);

    try {
      final ApiResponse<ActivityLogsResponse> response =
          await _repository.fetchActivityLogs(
        page: targetPage,
        pageSize: targetPageSize,
      );

      if (response.success && response.data != null) {
        _logs = response.data!.logs;
        _pagination = response.data!.pagination;
        _currentPage = _pagination?.page ?? targetPage;
        _pageSize = _pagination?.pageSize ?? targetPageSize;
        notifyListeners();
        return (success: true, message: response.message ?? 'Logs loaded');
      } else {
        _logs = [];
        _pagination = null;
        _setError(response.message ?? 'Failed to load activity logs');
        notifyListeners();
        return (success: false, message: response.message);
      }
    } catch (e) {
      _logs = [];
      _pagination = null;
      final message = 'Failed to load activity logs: $e';
      _setError(message);
      notifyListeners();
      return (success: false, message: message);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    await loadLogs(page: _currentPage, pageSize: _pageSize, forceRefresh: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
  }
}
