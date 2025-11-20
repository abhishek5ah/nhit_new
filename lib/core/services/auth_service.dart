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

// Enhanced result classes with error details
class AuthResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? errorData;
  final ErrorType? errorType;

  AuthResult({
    required this.success,
    this.message,
    this.errorData,
    this.errorType,
  });

  bool get isDuplicateEmail => errorType == ErrorType.duplicateEmail;
  bool get isDuplicateCode => errorType == ErrorType.duplicateCode;
  bool get isDuplicateTenant => errorType == ErrorType.duplicateTenant;
  bool get isValidationError => errorType == ErrorType.validation;
  bool get isServerError => errorType == ErrorType.serverError;
}

class TenantResult {
  final bool success;
  final String? message;
  final TenantResponse? data;
  final Map<String, dynamic>? errorData;
  final ErrorType? errorType;

  TenantResult({
    required this.success,
    this.message,
    this.data,
    this.errorData,
    this.errorType,
  });

  bool get isDuplicateEmail => errorType == ErrorType.duplicateEmail;
}

class OrganizationResult {
  final bool success;
  final String? message;
  final OrganizationResponse? data;
  final Map<String, dynamic>? errorData;
  final ErrorType? errorType;

  OrganizationResult({
    required this.success,
    this.message,
    this.data,
    this.errorData,
    this.errorType,
  });

  bool get isDuplicateCode => errorType == ErrorType.duplicateCode;
  bool get isDuplicateEmail => errorType == ErrorType.duplicateEmail;
}

enum ErrorType {
  duplicateEmail,
  duplicateCode,
  duplicateTenant,
  validation,
  serverError,
  networkError,
  unknown,
}

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

  // Parse error message and determine error type
  ({String message, ErrorType errorType}) _parseError(dynamic error, int? statusCode) {
    String errorMessage = '';
    ErrorType errorType = ErrorType.unknown;

    try {
      // Handle different error response formats
      if (error is Map<String, dynamic>) {
        errorMessage = error['message']?.toString() ?? 
                      error['error']?.toString() ?? 
                      error['details']?.toString() ?? 
                      'An error occurred';
      } else if (error is String) {
        errorMessage = error;
      } else {
        errorMessage = error.toString();
      }

      final lowerMessage = errorMessage.toLowerCase();

      // Check for duplicate key errors
      if (lowerMessage.contains('duplicate') || lowerMessage.contains('already exists')) {
        if (lowerMessage.contains('email')) {
          errorType = ErrorType.duplicateEmail;
          errorMessage = 'This email is already registered. Please use a different email or try logging in.';
        } else if (lowerMessage.contains('code') || lowerMessage.contains('organization')) {
          errorType = ErrorType.duplicateCode;
          errorMessage = 'This organization code already exists. Please use a different code.';
        } else if (lowerMessage.contains('tenant')) {
          errorType = ErrorType.duplicateTenant;
          errorMessage = 'This tenant already exists.';
        } else {
          errorMessage = 'This information already exists in the system. Please use different values.';
        }
      }
      // MongoDB duplicate key error (E11000)
      else if (lowerMessage.contains('e11000') || lowerMessage.contains('duplicate key')) {
        if (lowerMessage.contains('email')) {
          errorType = ErrorType.duplicateEmail;
          errorMessage = 'This email is already registered. Please use a different email.';
        } else if (lowerMessage.contains('code')) {
          errorType = ErrorType.duplicateCode;
          errorMessage = 'This organization code already exists. Please use a different code.';
        } else {
          errorMessage = 'This information already exists in the system.';
        }
      }
      // PostgreSQL unique constraint
      else if (lowerMessage.contains('unique constraint') || lowerMessage.contains('unique_violation')) {
        if (lowerMessage.contains('email')) {
          errorType = ErrorType.duplicateEmail;
          errorMessage = 'This email is already registered.';
        } else if (lowerMessage.contains('code')) {
          errorType = ErrorType.duplicateCode;
          errorMessage = 'This organization code already exists.';
        } else {
          errorMessage = 'This information already exists.';
        }
      }
      // Validation errors
      else if (statusCode == 400 || lowerMessage.contains('validation') || lowerMessage.contains('invalid')) {
        errorType = ErrorType.validation;
      }
      // Server errors
      else if (statusCode != null && statusCode >= 500) {
        errorType = ErrorType.serverError;
        if (!lowerMessage.contains('server')) {
          errorMessage = 'Server error: $errorMessage';
        }
      }
      // Network errors
      else if (lowerMessage.contains('network') || lowerMessage.contains('connection')) {
        errorType = ErrorType.networkError;
        errorMessage = 'Network error. Please check your connection and try again.';
      }

    } catch (e) {
      print('🚨 [AuthService] Error parsing error message: $e');
      errorMessage = 'An unexpected error occurred';
      errorType = ErrorType.unknown;
    }

    return (message: errorMessage, errorType: errorType);
  }

  // Check authentication status
  Future<AuthResult> checkAuthStatus() async {
    try {
      final isAuth = await JwtTokenManager.isAuthenticated();
      final isEmailVerif = await JwtTokenManager.isEmailVerified();
      
      if (isAuth) {
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
      
      return AuthResult(success: true);
    } catch (e) {
      _isAuthenticated = false;
      _emailVerified = false;
      _currentUser = null;
      notifyListeners();
      return AuthResult(
        success: false,
        message: 'Failed to check auth status: $e',
        errorType: ErrorType.unknown,
      );
    }
  }

  // STEP 1: Create Tenant with enhanced error handling
  Future<TenantResult> createTenant(String name, String email, String password) async {
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
      
      print('📥 [AuthService] Repository response - Success: ${response.success}');
      
      if (response.success && response.data != null) {
        print('✅ [AuthService] Tenant creation successful');
        
        _currentTenantId = response.data!.tenantId;
        _currentUserName = name;
        _currentUserEmail = email;
        _currentUserPassword = password;
        
        await saveTenantIdForEmail(email, response.data!.tenantId);
        print('📝 [AuthService] Saved tenant ID mapping for email: $email');
        
        notifyListeners();
        print('🎉 [AuthService] Tenant creation completed successfully');
        
        return TenantResult(
          success: true,
          message: response.message ?? 'Tenant created successfully',
          data: response.data,
        );
      } else {
        print('❌ [AuthService] Tenant creation failed - Message: ${response.message}');
        
        // Parse error
        final errorInfo = _parseError(response.message, response.statusCode);
        
        return TenantResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
          errorData: response.errorData,
        );
      }
    } catch (e, stackTrace) {
      print('🚨 [AuthService] ERROR in createTenant:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      
      final errorInfo = _parseError(e, null);
      
      return TenantResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      print('🏁 [AuthService] Setting loading to false');
      _setLoading(false);
    }
  }

  // STEP 2: Create Organization with enhanced error handling
  Future<OrganizationResult> createOrganization({
    required String organizationName,
    required String organizationCode,
    required String description,
    List<String> initialProjects = const [],
  }) async {
    print('🏢 [AuthService] Starting createOrganization for: $organizationName');
    _setLoading(true);
    
    try {
      if (_currentTenantId == null || _currentUserEmail == null || _currentUserPassword == null || _currentUserName == null) {
        print('❌ [AuthService] Session expired - tenant data not found');
        return OrganizationResult(
          success: false,
          message: 'Session expired. Please start registration again.',
          errorType: ErrorType.validation,
        );
      }
      
      print('✅ [AuthService] Session valid - tenant ID: $_currentTenantId');
      
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
      
      if (response.success && response.data != null) {
        print('✅ [AuthService] Organization creation successful');
        
        _organizationData = response.data!;
        notifyListeners();
        
        return OrganizationResult(
          success: true,
          message: response.data!.message,
          data: response.data,
        );
      } else {
        print('❌ [AuthService] Organization creation failed: ${response.message}');
        
        final errorInfo = _parseError(response.message, response.statusCode);
        
        return OrganizationResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
          errorData: response.errorData,
        );
      }
    } catch (e, stackTrace) {
      print('🚨 [AuthService] ERROR in createOrganization:');
      print('   Error: $e');
      print('   StackTrace: $stackTrace');
      
      final errorInfo = _parseError(e, null);
      
      return OrganizationResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Create Organization from Logged-in State with enhanced error handling
  Future<OrganizationResult> createOrganizationFromLoggedInState({
    required String organizationName,
    required String organizationCode,
    required String description,
    required String superAdminName,
    required String superAdminEmail,
    required String superAdminPassword,
    List<String> initialProjects = const [],
  }) async {
    print('🏢 [AuthService] Creating organization from logged-in state: $organizationName');
    _setLoading(true);
    
    try {
      final tenantId = await JwtTokenManager.getTenantId();
      if (tenantId == null || tenantId.isEmpty) {
        print('❌ [AuthService] No tenant ID found in JWT token');
        return OrganizationResult(
          success: false,
          message: 'User not properly authenticated. Please login again.',
          errorType: ErrorType.validation,
        );
      }
      
      print('✅ [AuthService] Using tenant ID from JWT: $tenantId');
      
      final request = OrganizationRequest(
        tenantId: tenantId,
        name: organizationName,
        code: organizationCode.toUpperCase(),
        description: description,
        superAdmin: SuperAdminRequest(
          name: superAdminName,
          email: superAdminEmail,
          password: superAdminPassword,
        ),
        initialProjects: initialProjects,
      );
      
      print('📡 [AuthService] Calling auth repository createOrganization');
      final response = await _authRepository.createOrganization(request);
      
      if (response.success && response.data != null) {
        print('✅ [AuthService] Organization created successfully');
        
        await saveTenantIdForEmail(superAdminEmail, tenantId);
        
        return OrganizationResult(
          success: true,
          message: response.data!.message,
          data: response.data,
        );
      } else {
        print('❌ [AuthService] Organization creation failed: ${response.message}');
        
        final errorInfo = _parseError(response.message, response.statusCode);
        
        return OrganizationResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
          errorData: response.errorData,
        );
      }
    } catch (e) {
      print('🚨 [AuthService] Exception in createOrganizationFromLoggedInState: $e');
      
      final errorInfo = _parseError(e, null);
      
      return OrganizationResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Register new user (old method - kept for compatibility)
  Future<AuthResult> register(RegisterRequest request) async {
    _setLoading(true);
    
    try {
      final response = await _authRepository.register(request);
      
      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return AuthResult(success: true, message: response.message);
      } else {
        final errorInfo = _parseError(response.message, response.statusCode);
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e) {
      final errorInfo = _parseError(e, null);
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // STEP 3: Login user
  Future<AuthResult> login(String email, String password, {String? tenantId}) async {
    print('🔑 [AuthService] Starting login for email: $email');
    _setLoading(true);
    
    try {
      final request = LoginRequest(
        tenantId: tenantId,
        login: email,
        password: password,
      );
      
      print('📡 [AuthService] Calling auth repository login');
      final response = await _authRepository.login(request);
      
      if (response.success && response.data != null) {
        print('✅ [AuthService] Login successful');
        
        await _saveLoginData(response.data!);
        await saveTenantIdForEmail(email, response.data!.tenantId);
        clearStoredData();
        
        return AuthResult(success: true, message: 'Login successful');
      } else {
        print('❌ [AuthService] Login failed: ${response.message}');
        
        final errorInfo = _parseError(response.message, response.statusCode);
        
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e, stackTrace) {
      print('🚨 [AuthService] ERROR in login: $e');
      
      final errorInfo = _parseError(e, null);
      
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Login with SSO
  Future<AuthResult> loginWithSSO(String provider, String idToken) async {
    _setLoading(true);
    
    try {
      final response = await _authRepository.ssoComplete(provider, idToken);
      
      if (response.success && response.data != null) {
        await _saveAuthData(response.data!);
        return AuthResult(success: true, message: response.message);
      } else {
        final errorInfo = _parseError(response.message, response.statusCode);
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e) {
      final errorInfo = _parseError(e, null);
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Verify email
  Future<AuthResult> verifyEmail(String token) async {
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
        return AuthResult(success: true, message: response.message);
      } else {
        final errorInfo = _parseError(response.message, response.statusCode);
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e) {
      final errorInfo = _parseError(e, null);
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Send verification email
  Future<AuthResult> sendVerificationEmail() async {
    _setLoading(true);
    
    try {
      final response = await _authRepository.sendVerificationEmail();
      
      if (response.success) {
        return AuthResult(success: true, message: response.message);
      } else {
        final errorInfo = _parseError(response.message, response.statusCode);
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e) {
      final errorInfo = _parseError(e, null);
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<AuthResult> forgotPassword(String email) async {
    _setLoading(true);
    
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _authRepository.forgotPassword(request);
      
      if (response.success) {
        return AuthResult(success: true, message: response.message);
      } else {
        final errorInfo = _parseError(response.message, response.statusCode);
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e) {
      final errorInfo = _parseError(e, null);
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<AuthResult> resetPassword(
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
      
      if (response.success) {
        return AuthResult(success: true, message: response.message);
      } else {
        final errorInfo = _parseError(response.message, response.statusCode);
        return AuthResult(
          success: false,
          message: errorInfo.message,
          errorType: errorInfo.errorType,
        );
      }
    } catch (e) {
      final errorInfo = _parseError(e, null);
      return AuthResult(
        success: false,
        message: errorInfo.message,
        errorType: errorInfo.errorType,
      );
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    print('🚪 [AuthService] Starting logout process');
    _setLoading(true);
    
    try {
      final token = await JwtTokenManager.getToken();
      
      if (token != null) {
        try {
          final response = await _authRepository.logout();
          if (response.success) {
            print('✅ [AuthService] Backend logout successful');
          }
        } catch (e) {
          print('⚠️ [AuthService] Backend logout error: $e');
        }
      }
    } finally {
      await _clearAuthData();
      _setLoading(false);
      print('🎉 [AuthService] Logout completed');
    }
  }

  // Save authentication data
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

  // Save login data
  Future<void> _saveLoginData(LoginResponse loginData) async {
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
    
    _currentUser = UserModel(
      id: loginData.userId,
      email: loginData.email,
      name: loginData.name,
      roles: loginData.roles,
      permissions: loginData.permissions,
      emailVerified: true,
      tenantId: loginData.tenantId,
      organizationId: loginData.orgId.isNotEmpty ? loginData.orgId : null,
      lastLoginAt: loginData.lastLoginAt,
      lastLoginIp: loginData.lastLoginIp,
    );
    
    _isAuthenticated = true;
    _emailVerified = true;
    notifyListeners();
  }

  // Clear stored data
  void clearStoredData() {
    _currentTenantId = null;
    _currentUserName = null;
    _currentUserEmail = null;
    _currentUserPassword = null;
    _organizationData = null;
  }

  // Enhanced authentication check
  Future<bool> checkIsAuthenticated() async {
    try {
      final token = await JwtTokenManager.getToken();
      if (token == null) return false;

      final isExpired = await JwtTokenManager.isTokenExpired();
      if (isExpired) {
        await _clearAuthData();
        return false;
      }

      final tenantId = await JwtTokenManager.getTenantId();
      if (tenantId == null || tenantId.isEmpty) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    await JwtTokenManager.clearTokens();
    _isAuthenticated = false;
    _emailVerified = false;
    _currentUser = null;
    clearStoredData();
    notifyListeners();
  }

  // Role-based access control
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

  // Remember tenant ID
  Future<void> saveTenantIdForEmail(String email, String tenantId) async {
    await JwtTokenManager.saveRememberedTenantId(email, tenantId);
  }

  Future<String?> getRememberedTenantId(String email) async {
    return await JwtTokenManager.getRememberedTenantId(email);
  }
}

// Global instance
final authService = AuthService();
