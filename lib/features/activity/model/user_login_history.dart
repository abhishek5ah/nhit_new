class UserLoginHistory {
  final String historyId;
  final String userId;
  final String userLabel;
  final DateTime loginTime;
  final String ipAddress;
  final String userAgent;

  UserLoginHistory({
    required this.historyId,
    required this.userId,
    required this.userLabel,
    required this.loginTime,
    required this.ipAddress,
    required this.userAgent,
  });

  factory UserLoginHistory.fromJson(
    Map<String, dynamic> json, {
    String? userLabel,
  }) {
    final loginTimeString = json['loginTime']?.toString() ?? '';
    DateTime loginTime;
    try {
      loginTime = DateTime.parse(loginTimeString).toLocal();
    } catch (_) {
      loginTime = DateTime.now();
    }

    final fallbackLabel =
        (userLabel != null && userLabel.isNotEmpty) ? userLabel : (json['userId']?.toString() ?? 'User');

    return UserLoginHistory(
      historyId: json['historyId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userLabel: fallbackLabel,
      loginTime: loginTime,
      ipAddress: json['ipAddress']?.toString() ?? '-',
      userAgent: json['userAgent']?.toString() ?? '-',
    );
  }
}

class UserLoginHistoryResponse {
  final List<UserLoginHistory> histories;
  final dynamic pagination;

  UserLoginHistoryResponse({
    required this.histories,
    this.pagination,
  });

  factory UserLoginHistoryResponse.fromJson(
    Map<String, dynamic> json, {
    String? userLabel,
  }) {
    final historiesJson = (json['histories'] as List?) ?? [];

    return UserLoginHistoryResponse(
      histories: historiesJson
          .whereType<Map<String, dynamic>>()
          .map((entry) => UserLoginHistory.fromJson(entry, userLabel: userLabel))
          .toList(),
      pagination: json['pagination'],
    );
  }
}
