import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import 'package:ppv_components/features/auth/data/models/organization_request.dart';
import 'package:ppv_components/features/auth/data/models/tenant_request.dart';
import 'package:ppv_components/features/auth/data/models/forgot_password_request.dart';
import 'package:ppv_components/features/auth/data/models/login_request.dart';
import 'package:ppv_components/features/auth/data/models/login_response.dart';
import 'package:ppv_components/features/auth/data/models/organization_response.dart';
import 'package:ppv_components/features/auth/data/models/register_request.dart';
import 'package:ppv_components/features/auth/data/models/reset_password_request.dart';
import 'package:ppv_components/features/auth/data/models/super_admin_register_request.dart';
import 'package:ppv_components/features/auth/data/models/tenant_response.dart';
import 'package:ppv_components/features/auth/data/models/user_model.dart';
import 'package:ppv_components/features/auth/data/models/verify_email_request.dart';
import 'package:ppv_components/features/auth/data/repositories/auth_repository.dart';


class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  bool _isAuthenticated = false;
  UserModel? _currentUser;
  bool _emailVerified = false;
  bool _isLoading = false;
  
  // Temporary storage for 3-step registration flow
  String? _currentTenantId;
  String? _currentUserName;
  String? _currentUserEmail;
  String? _currentUserPassword;
  OrganizationResponse? _organizationData;


  // Getters
  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  bool get emailVerified => _emailVerified;
  bool get isLoading => _isLoading;
  String? get currentTenantId => _currentTenantId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserPassword => _currentUserPassword;
  OrganizationResponse? get organizationData => _organizationData;


  // Initialize auth service
  Future<void> initialize() async {
    _setLoading(true);
    await checkAuthStatus();
    _setLoading(false);
  }


  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }


  // Check authentication status
  Future<({bool success, String? message})> checkAuthStatus() async {
    try {
      final isAuth = await JwtTokenManager.isAuthenticated();
      final isEmailVerif = await JwtTokenManager.isEmailVerified();
      
      if (isAuth) {
        // Try to get user info from token
        final payload = await JwtTokenManager.getTokenPayload();
        if (payload != null) {
          final email = await JwtTokenManager.getEmail();
          final userId = await JwtTokenManager.getUserId();
          
          _currentUser = UserModel(
            id: userId ?? payload['userId'] ?? '',
            email: email ?? payload['email'] ?? '',
            name: payload['name'] ?? '',
            roles: List<String>.from(payload['roles'] ?? []),
            permissions: List<String>.from(payload['permissions'] ?? []),
            emailVerified: isEmailVerif,
            tenantId: payload['tenantId'],
            organizationId: payload['orgId'],
          );
        }
      }
      
      _isAuthenticated = isAuth;
      _emailVerified = isEmailVerif;
      notifyListeners();
      
      return (success: true, message: null);
    } catch (e) {
      _isAuthenticated = false;
      _emailVerified = false;
      _currentUser = null;
      notifyListeners();
      return (success: false, message: 'Failed to check auth status: $e');
    }
  }


  // NEW STEP 1: Create Tenant (Replaces registerSuperAdmin)
  Future<({bool success, String? message, TenantResponse? data})> createTenant(String name, String email, String password) async {
    print('🚀 [AuthService] Starting createTenant for email: $email, name: $name');
    _setLoading(true);
    
    try {
      print('🔄 [AuthService] Creating TenantRequest object');
      final request = TenantRequest(
        name: name,
        email: email,
        password: password,
      );
      
      print('📡 [AuthService] Calling auth repository createTenant');
      final response = await _authRepository.createTenant(request);
      
      print('📥 [AuthService] Repository response - Success: ${response.success}, Data exists: ${response.data != null}');
      if (response.success && response.data != null) {
        print('✅ [AuthService] Tenant creation successful, processing response data');
        
        // Store tenant data for Step 2
        _currentTenantId = response.data!.tenantId;
        _currentUserName = name;
        _currentUserEmail = email;
        _currentUserPassword = password;
        print('💾 [AuthService] Stored tenant data - ID: ${response.data!.tenantId}, Name: $name, Email: $email');
        
        print('🔔 [AuthService] Calling notifyListeners to update UI');
        notifyListeners();
        print('🎉 [AuthService] Tenant creation completed successfully');
        return (success: true, message: response.message ?? 'Tenant created successfully', data: response.data);
      } else {
        print('❌ [AuthService] Tenant creation failed - Message: ${response.message}');
        return (success: false, message: response.message ?? 'Tenant creation failed', data: null);
      }
    } catch (e, stackTrace) {
      print('🚨 [AuthService] ERROR in createTenant:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      return (success: false, message: 'Tenant creation failed: $e', data: null);
    } finally {
      print('🏁 [AuthService] Setting loading to false');
      _setLoading(false);
    }
  }


  // LEGACY STEP 1: Super Admin Registration (DEPRECATED - Use createTenant instead)
  @deprecated
  Future<({bool success, String? message})> registerSuperAdmin(String name, String email, String password) async {
    print('⚠️  [AuthService] DEPRECATED: registerSuperAdmin called. Use createTenant instead.');
    final result = await createTenant(name, email, password);
    return (success: result.success, message: result.message);
  }


  // STEP 2: Create Organization (Updated for new flow)
  Future<({bool success, String? message, OrganizationResponse? data})> createOrganization({
    required String organizationName,
    required String organizationCode,
    required String description,
    List<String> initialProjects = const [],
  }) async {
    print('🏢 [AuthService] Starting createOrganization for: $organizationName (Code: $organizationCode)');
    _setLoading(true);
    
    try {
      // Check if temporary data from Step 1 is available
      if (_currentTenantId == null || _currentUserEmail == null || _currentUserPassword == null || _currentUserName == null) {
        print('❌ [AuthService] Session expired - tenant data not found');
        return (success: false, message: 'Session expired. Please start registration again.', data: null);
      }
      
      print('✅ [AuthService] Session valid - using tenant ID: $_currentTenantId, email: $_currentUserEmail');
      print('🔄 [AuthService] Creating CreateOrganizationRequest object');
      
      final request = OrganizationRequest(
        tenantId: _currentTenantId!,
        name: organizationName,
        code: organizationCode.toUpperCase(),
        description: description,
        superAdmin: SuperAdminRequest(
          name: _currentUserName!,
          email: _currentUserEmail!,
          password: _currentUserPassword!,
        ),
        initialProjects: initialProjects,
      );
      
      print('📡 [AuthService] Calling auth repository createOrganization');
      final response = await _authRepository.createOrganization(request);
      
      print('📥 [AuthService] Organization response - Success: ${response.success}, Data exists: ${response.data != null}');
      if (response.success && response.data != null) {
        print('✅ [AuthService] Organization creation successful, processing response');
        
        // Store organization data
        _organizationData = response.data!;
        print('🏛️ [AuthService] Stored organization data: ${response.data!.organization.name}');
        
        // NOTE: Do NOT set authenticated here - user still needs to login (Step 3)
        print('ℹ️  [AuthService] Organization created, but user still needs to login for JWT tokens');
        
        print('🔔 [AuthService] Calling notifyListeners to update UI');
        notifyListeners();
        print('🎉 [AuthService] Organization creation completed successfully');
        return (success: true, message: response.data!.message, data: response.data);
      } else {
        print('❌ [AuthService] Organization creation failed - Message: ${response.message}');
        return (success: false, message: response.message ?? 'Organization creation failed', data: null);
      }
    } catch (e, stackTrace) {
      print('🚨 [AuthService] ERROR in createOrganization:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      return (success: false, message: 'Organization creation failed: $e', data: null);
    } finally {
      print('🏁 [AuthService] Setting loading to false');
      _setLoading(false);
    }
  }


  // Register new user (old method - kept for compatibility)
  Future<({bool success, String? message})> register(RegisterRequest request) async {
    _setLoading(true);
    
    try {
      final response = await _authRepository.register(request);
      
      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      return (success: false, message: 'Registration failed: $e');
    } finally {
      _setLoading(false);
    }
  }


  // STEP 3: Login user (existing Super Admin)
  Future<({bool success, String? message})> login(String tenantId, String email, String password) async {
    print('🔑 [AuthService] Starting login for email: $email, tenantId: $tenantId');
    _setLoading(true);
    
    try {
      print('🔄 [AuthService] Creating LoginRequest object');
      final request = LoginRequest(
        tenantId: tenantId,
        login: email, // Using email as login
        password: password,
      );
      
      print('📡 [AuthService] Calling auth repository login');
      final response = await _authRepository.login(request);
      
      print('📥 [AuthService] Login response - Success: ${response.success}, Data exists: ${response.data != null}');
      if (response.success && response.data != null) {
        print('✅ [AuthService] Login successful, processing response data');
        
        final loginData = response.data!;
        print('🔑 [AuthService] Login data - Token present: ${loginData.token.isNotEmpty}');
        print('👤 [AuthService] User ID: ${loginData.userId}');
        print('🏢 [AuthService] Tenant ID: ${loginData.tenantId}');
        print('🏛️ [AuthService] Org ID: ${loginData.orgId}');
        
        print('💾 [AuthService] Saving authentication data');
        await _saveLoginData(loginData);
        
        // Remember tenant ID for this email for future logins
        await saveTenantIdForEmail(email, tenantId);
        print('📝 [AuthService] Remembered tenant ID for email: $email');
        
        // Clear stored tenant data after successful login
        clearStoredData();
        
        print('🎉 [AuthService] Login completed successfully');
        return (success: true, message: 'Login successful');
      } else {
        print('❌ [AuthService] Login failed - Message: ${response.message}');
        return (success: false, message: response.message ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      print('🚨 [AuthService] ERROR in login:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      return (success: false, message: 'Login failed: $e');
    } finally {
      print('🏁 [AuthService] Setting loading to false');
      _setLoading(false);
    }
  }


  // Login with SSO
  Future<({bool success, String? message})> loginWithSSO(
    String provider,
    String idToken,
  ) async {
    _setLoading(true);
    
    try {
      final response = await _authRepository.ssoComplete(provider, idToken);
      
      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      return (success: false, message: 'SSO login failed: $e');
    } finally {
      _setLoading(false);
    }
  }


  // Verify email
  Future<({bool success, String? message})> verifyEmail(String token) async {
    _setLoading(true);
    
    try {
      final request = VerifyEmailRequest(token: token);
      final response = await _authRepository.verifyEmail(request);
      
      if (response.success) {
        await JwtTokenManager.updateEmailVerificationStatus(true);
        _emailVerified = true;
        if (_currentUser != null) {
          _currentUser = _currentUser!.copyWith(emailVerified: true);
        }
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      return (success: false, message: 'Email verification failed: $e');
    } finally {
      _setLoading(false);
    }
  }


  // Send verification email
  Future<({bool success, String? message})> sendVerificationEmail() async {
    _setLoading(true);
    
    try {
      final response = await _authRepository.sendVerificationEmail();
      return (success: response.success, message: response.message);
    } catch (e) {
      return (success: false, message: 'Failed to send verification email: $e');
    } finally {
      _setLoading(false);
    }
  }


  // Forgot password
  Future<({bool success, String? message})> forgotPassword(String email) async {
    _setLoading(true);
    
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authRepository.forgotPassword(request);
      return (success: response.success, message: response.message);
    } catch (e) {
      return (success: false, message: 'Failed to send reset email: $e');
    } finally {
      _setLoading(false);
    }
  }


  // Reset password
  Future<({bool success, String? message})> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    _setLoading(true);
    
    try {
      final request = ResetPasswordRequest(
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      );
      final response = await _authRepository.resetPassword(request);
      return (success: response.success, message: response.message);
    } catch (e) {
      return (success: false, message: 'Password reset failed: $e');
    } finally {
      _setLoading(false);
    }
  }


  // Logout user - UNIFIED METHOD
  Future<void> logout() async {
    print('🚪 [AuthService] Starting logout process');
    _setLoading(true);
    
    try {
      // Get current token for logout request
      final token = await JwtTokenManager.getToken();
      
      if (token != null) {
        print('📡 [AuthService] Calling backend logout endpoint');
        // Call backend logout endpoint with token
        try {
          final response = await _authRepository.logout();
          if (response.success) {
            print('✅ [AuthService] Backend logout successful');
          }
        } catch (e) {
          print('⚠️ [AuthService] Backend logout error: $e');
          // Continue with local cleanup even if backend fails
        }
      }
    } catch (e) {
      print('🚨 [AuthService] Error during logout: $e');
    } finally {
      // ALWAYS clear local storage regardless of API response
      print('🧹 [AuthService] Clearing local authentication data');
      await _clearAuthData();
      _setLoading(false);
      print('🎉 [AuthService] Logout completed successfully');
    }
  }


  // Save authentication data (legacy method for old AuthResponse)
  Future<void> _saveAuthData(dynamic authData, {String? tenantId}) async {
    await JwtTokenManager.saveTokens(
      accessToken: authData.accessToken,
      refreshToken: authData.refreshToken,
      userId: authData.user.id,
      email: authData.user.email,
      emailVerified: authData.user.emailVerified,
      tenantId: tenantId,
    );
    
    _isAuthenticated = true;
    _emailVerified = authData.user.emailVerified;
    _currentUser = authData.user;
    notifyListeners();
  }


  // Save login data (new method for LoginResponse)
  Future<void> _saveLoginData(LoginResponse loginData) async {
    print('💾 [AuthService] Saving login data to JWT token manager');
    
    // Save tokens and user data using new format
    await JwtTokenManager.saveLoginTokens(
      token: loginData.token,
      refreshToken: loginData.refreshToken,
      userId: loginData.userId,
      email: loginData.email,
      name: loginData.name,
      tenantId: loginData.tenantId,
      orgId: loginData.orgId,
      tokenExpiresAt: loginData.tokenExpiresAt,
      refreshExpiresAt: loginData.refreshExpiresAt,
      roles: loginData.roles,
      permissions: loginData.permissions,
      lastLoginAt: loginData.lastLoginAt,
      lastLoginIp: loginData.lastLoginIp,
    );
    
    // Update current user model
    _currentUser = UserModel(
      id: loginData.userId,
      email: loginData.email,
      name: loginData.name,
      roles: loginData.roles,
      permissions: loginData.permissions,
      emailVerified: true, // Assume verified if login successful
      tenantId: loginData.tenantId,
      organizationId: loginData.orgId.isNotEmpty ? loginData.orgId : null,
      lastLoginAt: loginData.lastLoginAt,
      lastLoginIp: loginData.lastLoginIp,
    );
    
    _isAuthenticated = true;
    _emailVerified = true; // Assume verified if login successful
    
    print('✅ [AuthService] Login data saved successfully');
    notifyListeners();
  }


  // Clear stored tenant/organization data (call after successful login or on error)
  void clearStoredData() {
    _currentTenantId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserPassword = null;
    _organizationData = null;
    print('🧹 [AuthService] Cleared all stored tenant/organization data');
  }


  // Enhanced authentication check with token validation
  Future<bool> checkIsAuthenticated() async {
    try {
      // Check if we have a token
      final token = await JwtTokenManager.getToken();
      if (token == null) {
        print('❌ [AuthService] No token found');
        return false;
      }

      // Check if token is expired
      final isExpired = await JwtTokenManager.isTokenExpired();
      if (isExpired) {
        print('⏰ [AuthService] Token is expired');
        await _clearAuthData();
        return false;
      }

      // Check if we have tenant ID (required for proper authentication)
      final tenantId = await JwtTokenManager.getTenantId();
      if (tenantId == null || tenantId.isEmpty) {
        print('🏢 [AuthService] No tenant ID found');
        return false;
      }

      print('✅ [AuthService] User is authenticated');
      return true;
    } catch (e) {
      print('🚨 [AuthService] Error checking authentication: $e');
      return false;
    }
  }


  // Clear authentication data
  Future<void> _clearAuthData() async {
    await JwtTokenManager.clearTokens();
    _isAuthenticated = false;
    _emailVerified = false;
    _currentUser = null;
    clearStoredData(); // Also clear tenant data
    notifyListeners();
  }


  // Role-based access control helpers
  bool get isSuperAdmin => _currentUser?.roles.contains('superadmin') ?? false;
  bool get isAdmin => _currentUser?.roles.contains('admin') ?? false;
  bool get isUser => _currentUser?.roles.contains('user') ?? false;
  
  bool hasRole(String role) => _currentUser?.roles.contains(role) ?? false;
  bool hasPermission(String permission) => _currentUser?.permissions.contains(permission) ?? false;
  
  bool hasAnyRole(List<String> roles) {
    if (_currentUser == null) return false;
    return roles.any((role) => _currentUser!.roles.contains(role));
  }
  
  bool hasAnyPermission(List<String> permissions) {
    if (_currentUser == null) return false;
    return permissions.any((permission) => _currentUser!.permissions.contains(permission));
  }


  // Remember tenant ID for convenience (optional feature)
  Future<void> saveTenantIdForEmail(String email, String tenantId) async {
    await JwtTokenManager.saveRememberedTenantId(email, tenantId);
  }


  Future<String?> getRememberedTenantId(String email) async {
    return await JwtTokenManager.getRememberedTenantId(email);
  }
}


// Global instance
final authService = AuthService();
