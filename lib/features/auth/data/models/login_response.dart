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
      String _stringValue(dynamic value) => value?.toString() ?? '';
      List<String> _listValue(dynamic value) {
        if (value == null) return [];
        if (value is List) {
          return value.map((item) => item.toString()).toList();
        }
        return value.toString().isNotEmpty ? [value.toString()] : [];
      }

      dynamic _pick(List<String> keys) {
        for (final key in keys) {
          if (json.containsKey(key)) {
            final value = json[key];
            if (value != null && value.toString().isNotEmpty) {
              return value;
            }
          }
        }
        return null;
      }

      final response = LoginResponse(
        token: _stringValue(_pick(['token', 'access_token'])),
        refreshToken: _stringValue(_pick(['refreshToken', 'refresh_token'])),
        userId: _stringValue(_pick(['userId', 'user_id'])),
        email: _stringValue(json['email']),
        name: _stringValue(json['name']),
        roles: _listValue(json['roles']),
        permissions: _listValue(json['permissions']),
        lastLoginAt: _stringValue(_pick(['lastLoginAt', 'last_login_at'])),
        lastLoginIp: _stringValue(_pick(['lastLoginIp', 'last_login_ip'])),
        tenantId: _stringValue(_pick(['tenantId', 'tenant_id'])),
        orgId: _stringValue(_pick(['orgId', 'org_id'])),
        tokenExpiresAt: _stringValue(_pick(['tokenExpiresAt', 'token_expires_at'])),
        refreshExpiresAt: _stringValue(_pick(['refreshExpiresAt', 'refresh_expires_at'])),
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
