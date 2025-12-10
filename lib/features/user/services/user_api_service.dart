// ============================================================================
// USER API SERVICE
// Service layer for user management with state management
// Handles all user operations with reactive updates
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/user/data/models/user_api_models.dart';
import 'package:ppv_components/features/user/data/repositories/user_api_repository.dart';

class UserApiService extends ChangeNotifier {
  final UserApiRepository _repository = UserApiRepository();

  List<UserApiModel> _users = [];
  UserApiModel? _currentUser;
  UserPagination? _pagination;
  bool _isLoading = false;
  String? _error;

  // Dropdown caches
  List<DropdownItem> _departments = [];
  List<DropdownItem> _designations = [];
  List<DropdownItem> _roles = [];
  bool _isDropdownsLoading = false;
  String? _dropdownsError;

  // Getters
  List<UserApiModel> get users => _users;
  UserApiModel? get currentUser => _currentUser;
  UserPagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUsers => _users.isNotEmpty;

  List<DropdownItem> get departments => _departments;
  List<DropdownItem> get designations => _designations;
  List<DropdownItem> get roles => _roles;
  bool get isDropdownsLoading => _isDropdownsLoading;
  String? get dropdownsError => _dropdownsError;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setDropdownsLoading(bool loading) {
    _isDropdownsLoading = loading;
    notifyListeners();
  }

  void _setDropdownsError(String? error) {
    _dropdownsError = error;
    notifyListeners();
  }

  // ============================================================================
  // 1. LOAD USERS (PAGINATED)
  // ============================================================================
  Future<({bool success, String? message})> loadUsers({
    int page = 1,
    int pageSize = 10,
    bool forceRefresh = false,
  }) async {
    print('👥 [UserApiService] Loading users - Page: $page');

    // Use cache if available and not forcing refresh
    if (!forceRefresh && _users.isNotEmpty && _pagination?.page == page) {
      return (success: true, message: 'Users loaded from cache');
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getUsers(
        page: page,
        pageSize: pageSize,
      );

      if (response.success && response.data != null) {
        _users = response.data!.users;
        _pagination = response.data!.pagination;
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      _setError('Failed to load users: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to load users: $e');
    }
  }

  // ============================================================================
  // 2. GET USER BY ID
  // ============================================================================
  Future<({bool success, String? message, UserApiModel? user})> getUserById(
    String userId,
  ) async {
    print('👤 [UserApiService] Fetching user: $userId');

    try {
      final response = await _repository.getUserById(userId);

      if (response.success && response.data != null) {
        _currentUser = response.data;
        notifyListeners();
        return (success: true, message: response.message, user: response.data);
      } else {
        return (success: false, message: response.message, user: null);
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      return (success: false, message: 'Failed to fetch user: $e', user: null);
    }
  }

  // ============================================================================
  // 3. CREATE USER
  // ============================================================================
  Future<({bool success, String? message, UserApiModel? user})> createUser(
    CreateUserRequest request,
  ) async {
    print('👤 [UserApiService] Creating user: ${request.email}');

    try {
      final response = await _repository.createUser(request);

      if (response.success && response.data != null) {
        // Add to local list
        _users.insert(0, response.data!);
        notifyListeners();
        return (success: true, message: response.message, user: response.data);
      } else {
        return (success: false, message: response.message, user: null);
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      return (success: false, message: 'Failed to create user: $e', user: null);
    }
  }

  // ============================================================================
  // 4. UPDATE USER
  // ============================================================================
  Future<({bool success, String? message, UserApiModel? user})> updateUser(
    UpdateUserRequest request,
  ) async {
    print('👤 [UserApiService] Updating user: ${request.userId}');

    try {
      final response = await _repository.updateUser(request);

      if (response.success && response.data != null) {
        // Update in local list
        final index = _users.indexWhere((u) => u.userId == request.userId);
        if (index != -1) {
          _users[index] = response.data!;
        }
        
        // Update current user if it's the same
        if (_currentUser?.userId == request.userId) {
          _currentUser = response.data;
        }
        
        notifyListeners();
        return (success: true, message: response.message, user: response.data);
      } else {
        return (success: false, message: response.message, user: null);
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      return (success: false, message: 'Failed to update user: $e', user: null);
    }
  }

  // ============================================================================
  // 5. UPLOAD SIGNATURE
  // ============================================================================
  Future<({bool success, String? message, String? fileUrl})> uploadSignature(
    UploadSignatureRequest request,
  ) async {
    print('📸 [UserApiService] Uploading signature for: ${request.userId}');

    try {
      final response = await _repository.uploadSignature(request);

      if (response.success && response.data != null) {
        return (
          success: true,
          message: response.data!.message,
          fileUrl: response.data!.fileUrl
        );
      } else {
        return (success: false, message: response.message, fileUrl: null);
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      return (
        success: false,
        message: 'Failed to upload signature: $e',
        fileUrl: null
      );
    }
  }

  // ============================================================================
  // 6. GET USER ORGANIZATIONS
  // ============================================================================
  Future<({bool success, String? message, List<UserOrganization> organizations})>
      getUserOrganizations(String userId) async {
    print('🏢 [UserApiService] Fetching organizations for user: $userId');

    try {
      final response = await _repository.getUserOrganizations(userId);

      if (response.success && response.data != null) {
        return (
          success: true,
          message: response.message,
          organizations: response.data!.organizations
        );
      } else {
        return (
          success: false,
          message: response.message,
          organizations: const <UserOrganization>[]
        );
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      return (
        success: false,
        message: 'Failed to fetch organizations: $e',
        organizations: const <UserOrganization>[]
      );
    }
  }

  // ============================================================================
  // 7. ADD USER TO ORGANIZATION
  // ============================================================================
  Future<({bool success, String? message})> addUserToOrganization(
    AddUserToOrgRequest request,
  ) async {
    print('🏢 [UserApiService] Adding user to organization');

    try {
      final response = await _repository.addUserToOrganization(request);

      if (response.success) {
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [UserApiService] Error: $e');
      return (success: false, message: 'Failed to add user to organization: $e');
    }
  }

  // ============================================================================
  // 8. LOAD DROPDOWNS
  // ============================================================================

  /// Load all dropdowns for a specific organization
  Future<({bool success, String? message})> loadDropdowns(
    String orgId, {
    bool forceRefresh = false,
  }) async {
    print('📋 [UserApiService] Loading dropdowns for org: $orgId');

    // Use cache if available
    if (!forceRefresh &&
        _departments.isNotEmpty &&
        _designations.isNotEmpty &&
        _roles.isNotEmpty) {
      return (success: true, message: 'Dropdowns loaded from cache');
    }

    _setDropdownsLoading(true);
    _setDropdownsError(null);

    try {
      // Load all dropdowns in parallel
      final results = await Future.wait([
        _repository.getDepartmentsDropdown(orgId),
        _repository.getDesignationsDropdown(orgId),
        _repository.getRolesDropdown(orgId),
      ]);

      final deptResponse = results[0];
      final desigResponse = results[1];
      final rolesResponse = results[2];

      if (deptResponse.success && deptResponse.data != null) {
        _departments = deptResponse.data!;
      }

      if (desigResponse.success && desigResponse.data != null) {
        _designations = desigResponse.data!;
      }

      if (rolesResponse.success && rolesResponse.data != null) {
        _roles = rolesResponse.data!;
      }

      _setDropdownsLoading(false);
      notifyListeners();

      return (success: true, message: 'Dropdowns loaded successfully');
    } catch (e) {
      print('🚨 [UserApiService] Error loading dropdowns: $e');
      _setDropdownsError('Failed to load dropdowns: $e');
      _setDropdownsLoading(false);
      return (success: false, message: 'Failed to load dropdowns: $e');
    }
  }

  /// Load departments dropdown
  Future<({bool success, String? message, List<DropdownItem> items})>
      loadDepartments(String orgId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _departments.isNotEmpty) {
      return (success: true, message: 'Loaded from cache', items: _departments);
    }

    try {
      final response = await _repository.getDepartmentsDropdown(orgId);
      if (response.success && response.data != null) {
        _departments = response.data!;
        notifyListeners();
        return (success: true, message: response.message, items: _departments);
      }
      return (success: false, message: response.message, items: const <DropdownItem>[]);
    } catch (e) {
      return (success: false, message: 'Error: $e', items: const <DropdownItem>[]);
    }
  }

  /// Load designations dropdown
  Future<({bool success, String? message, List<DropdownItem> items})>
      loadDesignations(String orgId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _designations.isNotEmpty) {
      return (
        success: true,
        message: 'Loaded from cache',
        items: _designations
      );
    }

    try {
      final response = await _repository.getDesignationsDropdown(orgId);
      if (response.success && response.data != null) {
        _designations = response.data!;
        notifyListeners();
        return (
          success: true,
          message: response.message,
          items: _designations
        );
      }
      return (success: false, message: response.message, items: const <DropdownItem>[]);
    } catch (e) {
      return (success: false, message: 'Error: $e', items: const <DropdownItem>[]);
    }
  }

  /// Load roles dropdown
  Future<({bool success, String? message, List<DropdownItem> items})> loadRoles(
    String orgId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _roles.isNotEmpty) {
      return (success: true, message: 'Loaded from cache', items: _roles);
    }

    try {
      final response = await _repository.getRolesDropdown(orgId);
      if (response.success && response.data != null) {
        _roles = response.data!;
        notifyListeners();
        return (success: true, message: response.message, items: _roles);
      }
      return (success: false, message: response.message, items: const <DropdownItem>[]);
    } catch (e) {
      return (success: false, message: 'Error: $e', items: const <DropdownItem>[]);
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Search users locally
  List<UserApiModel> searchUsers(String query) {
    if (query.isEmpty) return _users;

    final lowerQuery = query.toLowerCase();
    return _users.where((user) {
      return user.name.toLowerCase().contains(lowerQuery) ||
          user.email.toLowerCase().contains(lowerQuery) ||
          user.roles.any((role) => role.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Clear all cached data
  void clearCache() {
    _users = [];
    _currentUser = null;
    _pagination = null;
    _departments = [];
    _designations = [];
    _roles = [];
    _error = null;
    _dropdownsError = null;
    notifyListeners();
  }

  /// Refresh current page
  Future<({bool success, String? message})> refresh() async {
    return loadUsers(
      page: _pagination?.page ?? 1,
      pageSize: _pagination?.pageSize ?? 10,
      forceRefresh: true,
    );
  }
}
