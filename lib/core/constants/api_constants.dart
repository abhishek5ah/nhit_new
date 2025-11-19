class ApiConstants {
  // Microservices Base URLs
  static const String authBaseUrl = 'http://192.168.1.51:8083/api/v1';      // Auth Service
  static const String userBaseUrl = 'http://192.168.1.51:8083/api/v1';      // User Service  
  static const String organizationBaseUrl = 'http://192.168.1.51:8083/api/v1'; // Organization Service
  static const String departmentBaseUrl = 'http://192.168.1.51:8083/api/v1';   // Department Service
  static const String designationBaseUrl = 'http://192.168.1.51:8083/api/v1';  // Designation Service
  static const String vendorBaseUrl = 'http://192.168.1.51:8083/api/v1';       // Vendor Service
  
  // Main Base URL (fallback for legacy endpoints)
  static const String baseUrl = authBaseUrl;
  static const String mainBaseUrl = authBaseUrl;
  
  // For Android emulator testing (alternatives)
  static const String androidAuthBaseUrl = 'http://10.0.2.2:8083/api/v1';
  static const String androidUserBaseUrl = 'http://10.0.2.2:8083/api/v1';
  static const String androidOrganizationBaseUrl = 'http://10.0.2.2:8083/api/v1';
  
  // ============ AUTH SERVICE ENDPOINTS (Port 8051) ============
  // Authentication
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Password Management
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String sendResetEmail = '/auth/send-reset-email';
  
  // Organization Switching
  static const String switchOrganization = '/auth/switch-organization';
  
  // Legacy Auth Endpoints
  static const String verifyEmail = '/auth/verify-email';
  static const String sendVerification = '/auth/send-verification';
  static const String ssoInitiate = '/auth/sso/initiate';
  static const String ssoComplete = '/auth/sso/complete';
  static const String ssoLogoutInitiate = '/auth/sso/logout/initiate';
  static const String ssoLogoutComplete = '/auth/sso/logout/complete';
  
  // ============ USER SERVICE ENDPOINTS (Port 8052) ============
  static const String createTenant = '/tenants';  // Register user (first = Super Admin)
  static const String users = '/users';
  static const String userRoles = '/users'; // /users/{id}/roles
  
  // ============ ORGANIZATION SERVICE ENDPOINTS (Port 8053) ============
  static const String createOrganization = '/organizations';
  static const String getOrganizations = '/organizations';
  static const String getOrganizationsByTenant = '/tenants'; // GET /tenants/{tenantId}/organizations
  static const String getOrganizationByCode = '/organizations/code';
  static const String updateOrganization = '/organizations';
  static const String deleteOrganization = '/organizations';
  
  // ============ DEPARTMENT SERVICE ENDPOINTS (Port 8054) ============
  static const String departments = '/departments';
  static const String departmentsByOrg = '/departments/organization';
  
  // ============ DESIGNATION SERVICE ENDPOINTS (Port 8055) ============
  static const String designations = '/designations';
  static const String designationsByDept = '/designations/department';
  
  // ============ VENDOR SERVICE ENDPOINTS (Port 8056) ============
  static const String vendors = '/vendors';
  static const String vendorsByOrg = '/vendors/organization';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
