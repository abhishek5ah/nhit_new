class LoginResponse {
  final String token;
  final String refreshToken;
  final String userId;
  final String email;
  final String name;
  final List<String> roles;
  final List<String> permissions;
  final String lastLoginAt;
  final String lastLoginIp;
  final String tenantId;
  final String orgId;
  final String tokenExpiresAt;
  final String refreshExpiresAt;

  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.name,
    required this.roles,
    required this.permissions,
    required this.lastLoginAt,
    required this.lastLoginIp,
    required this.tenantId,
    required this.orgId,
    required this.tokenExpiresAt,
    required this.refreshExpiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 [LoginResponse] Starting LoginResponse JSON parsing...');
    print('📋 [LoginResponse] JSON keys present: ${json.keys.toList()}');
    
    try {
      final response = LoginResponse(
        token: json['token'] ?? '',
        refreshToken: json['refreshToken'] ?? '',
        userId: json['userId'] ?? '',
        email: json['email'] ?? '',
        name: json['name'] ?? '',
        roles: List<String>.from(json['roles'] ?? []),
        permissions: List<String>.from(json['permissions'] ?? []),
        lastLoginAt: json['lastLoginAt'] ?? '',
        lastLoginIp: json['lastLoginIp'] ?? '',
        tenantId: json['tenantId'] ?? '',
        orgId: json['orgId'] ?? '',
        tokenExpiresAt: json['tokenExpiresAt'] ?? '',
        refreshExpiresAt: json['refreshExpiresAt'] ?? '',
      );
      
      print('✅ [LoginResponse] LoginResponse parsing completed successfully');
      print('🔑 [LoginResponse] Token present: ${response.token.isNotEmpty}');
      print('👤 [LoginResponse] User ID: ${response.userId}');
      print('🏢 [LoginResponse] Tenant ID: ${response.tenantId}');
      print('🏛️ [LoginResponse] Org ID: ${response.orgId}');
      
      return response;
      
    } catch (e, stackTrace) {
      print('🚨 [LoginResponse] ERROR during LoginResponse parsing:');
      print('   JSON that failed to parse: $json');
      print('   Error: $e');
      print('   Stack Trace: $stackTrace');
      print('================== LOGIN RESPONSE ERROR END ==================');
      
      // Rethrow the error for upstream handling
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'userId': userId,
      'email': email,
      'name': name,
      'roles': roles,
      'permissions': permissions,
      'lastLoginAt': lastLoginAt,
      'lastLoginIp': lastLoginIp,
      'tenantId': tenantId,
      'orgId': orgId,
      'tokenExpiresAt': tokenExpiresAt,
      'refreshExpiresAt': refreshExpiresAt,
    };
  }
}
