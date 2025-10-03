class UserLoginHistory {
  final int id;
  final String user;
  final String loginAt;
  final String loginIp;
  final String userAgent;
  final String createdAt;

  UserLoginHistory({
    required this.id,
    required this.user,
    required this.loginAt,
    required this.loginIp,
    required this.userAgent,
    required this.createdAt,
  });
}
