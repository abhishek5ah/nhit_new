import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtTokenManager {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    webOptions: WebOptions(
      dbName: 'nhit_erp_storage',
      publicKey: 'nhit_erp_key',
    ),
  );

  // Storage keys (legacy)
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _emailKey = 'email';
  static const String _emailVerifiedKey = 'email_verified';
  static const String _tenantIdKey = 'tenant_id';
  
  // New storage keys for real API format
  static const String _tokenKey = 'token'; // Main access token
  static const String _nameKey = 'name';
  static const String _orgIdKey = 'org_id';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _refreshExpiresAtKey = 'refresh_expires_at';
  static const String _rolesKey = 'roles';
  static const String _permissionsKey = 'permissions';
  static const String _lastLoginAtKey = 'last_login_at';
  static const String _lastLoginIpKey = 'last_login_ip';

  // Save tokens and user info
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required bool emailVerified,
    String? tenantId,
  }) async {
    final futures = [
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _emailKey, value: email),
      _storage.write(key: _emailVerifiedKey, value: emailVerified.toString()),
    ];
    
    if (tenantId != null) {
      futures.add(_storage.write(key: _tenantIdKey, value: tenantId));
    }
    
    await Future.wait(futures);
  }

  // Save login tokens and user info (new format for real API)
  static Future<void> saveLoginTokens({
    required String token,
    required String refreshToken,
    required String userId,
    required String email,
    required String name,
    required String tenantId,
    required String orgId,
    required String tokenExpiresAt,
    required String refreshExpiresAt,
    required List<String> roles,
    required List<String> permissions,
    required String lastLoginAt,
    required String lastLoginIp,
  }) async {
    final futures = [
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _emailKey, value: email),
      _storage.write(key: _nameKey, value: name),
      _storage.write(key: _tenantIdKey, value: tenantId),
      _storage.write(key: _orgIdKey, value: orgId),
      _storage.write(key: _tokenExpiresAtKey, value: tokenExpiresAt),
      _storage.write(key: _refreshExpiresAtKey, value: refreshExpiresAt),
      _storage.write(key: _rolesKey, value: roles.join(',')),
      _storage.write(key: _permissionsKey, value: permissions.join(',')),
      _storage.write(key: _lastLoginAtKey, value: lastLoginAt),
      _storage.write(key: _lastLoginIpKey, value: lastLoginIp),
      _storage.write(key: _emailVerifiedKey, value: 'true'), // Assume verified if login successful
    ];
    
    await Future.wait(futures);
    print('💾 [JwtTokenManager] Saved all login tokens and user data');
  }

  // Get access token (tries new format first, then legacy)
  static Future<String?> getAccessToken() async {
    try {
      // Try new format first
      final newToken = await _storage.read(key: _tokenKey);
      if (newToken != null && newToken.isNotEmpty) {
        return newToken;
      }
      
      // Fall back to legacy format
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading access token: $e');
      return null;
    }
  }

  // Get token (new format)
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading token: $e');
      return null;
    }
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Get email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // Check if email is verified
  static Future<bool> isEmailVerified() async {
    try {
      final emailVerified = await _storage.read(key: _emailVerifiedKey);
      return emailVerified == 'true';
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading email verification status: $e');
      return false;
    }
  }

  // Get tenant ID
  static Future<String?> getTenantId() async {
    try {
      return await _storage.read(key: _tenantIdKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading tenant ID: $e');
      return null;
    }
  }

  // Get user name
  static Future<String?> getName() async {
    try {
      return await _storage.read(key: _nameKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading name: $e');
      return null;
    }
  }

  // Get organization ID
  static Future<String?> getOrgId() async {
    try {
      return await _storage.read(key: _orgIdKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading org ID: $e');
      return null;
    }
  }

  // Get token expiry timestamp
  static Future<String?> getTokenExpiresAt() async {
    try {
      return await _storage.read(key: _tokenExpiresAtKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading token expiry: $e');
      return null;
    }
  }

  // Get roles
  static Future<List<String>> getRoles() async {
    try {
      final rolesString = await _storage.read(key: _rolesKey);
      if (rolesString == null || rolesString.isEmpty) return [];
      return rolesString.split(',').where((role) => role.isNotEmpty).toList();
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading roles: $e');
      return [];
    }
  }

  // Get permissions
  static Future<List<String>> getPermissions() async {
    try {
      final permissionsString = await _storage.read(key: _permissionsKey);
      if (permissionsString == null || permissionsString.isEmpty) return [];
      return permissionsString.split(',').where((perm) => perm.isNotEmpty).toList();
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading permissions: $e');
      return [];
    }
  }

  // Get last login timestamp
  static Future<String?> getLastLoginAt() async {
    try {
      return await _storage.read(key: _lastLoginAtKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading last login timestamp: $e');
      return null;
    }
  }

  // Get last login IP
  static Future<String?> getLastLoginIp() async {
    try {
      return await _storage.read(key: _lastLoginIpKey);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error reading last login IP: $e');
      return null;
    }
  }

  // Save tenant ID
  static Future<void> saveTenantId(String tenantId) async {
    await _storage.write(key: _tenantIdKey, value: tenantId);
  }

  // Check if access token is expired (uses Unix timestamp if available)
  static Future<bool> isAccessTokenExpired() async {
    // Try to use Unix timestamp first (more accurate)
    final expiryTimestamp = await getTokenExpiresAt();
    if (expiryTimestamp != null && expiryTimestamp.isNotEmpty) {
      try {
        final expiryTime = int.parse(expiryTimestamp);
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        return currentTime >= expiryTime;
      } catch (e) {
        print('⚠️ [JwtTokenManager] Error parsing expiry timestamp: $e');
      }
    }
    
    // Fall back to JWT decoding
    final token = await getAccessToken();
    if (token == null) return true;
    
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  // Get token payload
  static Future<Map<String, dynamic>?> getTokenPayload() async {
    final token = await getAccessToken();
    if (token == null) return null;
    
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await getAccessToken();
      if (token == null) return false;
      
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error checking authentication: $e');
      // Fallback: assume authenticated if we have any token-like data
      return false;
    }
  }

  // Check if token will expire soon (within 5 minutes)
  static Future<bool> willExpireSoon() async {
    final token = await getAccessToken();
    if (token == null) return true;
    
    try {
      final expiryDate = JwtDecoder.getExpirationDate(token);
      final now = DateTime.now();
      final timeUntilExpiry = expiryDate.difference(now);
      
      // Return true if token expires within 5 minutes
      return timeUntilExpiry.inMinutes <= 5;
    } catch (e) {
      return true;
    }
  }

  // Clear all tokens and user data
  static Future<void> clearTokens() async {
    // Before clearing, save tenant ID mapping for this email
    final email = await getEmail();
    final tenantId = await getTenantId();
    
    if (email != null && email.isNotEmpty && tenantId != null && tenantId.isNotEmpty) {
      // Remember tenant ID for this email before clearing
      await saveRememberedTenantId(email, tenantId);
      print('💾 [JwtTokenManager] Saved tenant ID for $email before clearing tokens');
    }
    
    await Future.wait([
      // Legacy keys
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _emailVerifiedKey),
      _storage.delete(key: _tenantIdKey),
      // New keys
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _nameKey),
      _storage.delete(key: _orgIdKey),
      _storage.delete(key: _tokenExpiresAtKey),
      _storage.delete(key: _refreshExpiresAtKey),
      _storage.delete(key: _rolesKey),
      _storage.delete(key: _permissionsKey),
      _storage.delete(key: _lastLoginAtKey),
      _storage.delete(key: _lastLoginIpKey),
    ]);
    print('🧹 [JwtTokenManager] Cleared all tokens and user data (tenant mapping preserved)');
  }

  // Update email verification status
  static Future<void> updateEmailVerificationStatus(bool isVerified) async {
    await _storage.write(key: _emailVerifiedKey, value: isVerified.toString());
  }

  // Check if token is expired (alias for isAccessTokenExpired)
  static Future<bool> isTokenExpired() async {
    return await isAccessTokenExpired();
  }

  // Remember tenant ID for email (for better UX)
  static Future<void> saveRememberedTenantId(String email, String tenantId) async {
    await _storage.write(key: 'remembered_tenant_$email', value: tenantId);
  }

  static Future<String?> getRememberedTenantId(String email) async {
    try {
      return await _storage.read(key: 'remembered_tenant_$email');
    } catch (e) {
      print('⚠️ [JwtTokenManager] Error getting remembered tenant ID: $e');
      return null;
    }
  }

  // Save organization ID
  static Future<void> saveOrgId(String orgId) async {
    await _storage.write(key: _orgIdKey, value: orgId);
  }
}
