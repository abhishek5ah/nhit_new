import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';
import 'package:ppv_components/features/roles/data/repositories/roles_api_repository.dart';

/// Service layer for Role Management with state management
/// Handles CRUD operations and provides reactive updates
class RolesApiService extends ChangeNotifier {
  final IRolesApiRepository _repository;

  RolesApiService({IRolesApiRepository? repository})
      : _repository = repository ?? RolesApiRepository();
  
  List<RoleModel> _roles = [];
  List<PermissionModel> _availablePermissions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RoleModel> get roles => _roles;
  List<PermissionModel> get availablePermissions => _availablePermissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRoles => _roles.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Load all roles
  Future<({bool success, String? message})> loadRoles() async {
    print('📋 [RolesApiService] Loading roles');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getRoles();
      
      if (response.success && response.data != null) {
        _roles = response.data!.roles;
        print('✅ [RolesApiService] Loaded ${_roles.length} roles');
        _setLoading(false);
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [RolesApiService] Error: $e');
      _setError('Failed to load roles: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to load roles: $e');
    }
  }

  /// Load available permissions
  Future<({bool success, String? message})> loadPermissions() async {
    print('🔑 [RolesApiService] Loading permissions');
    
    try {
      final response = await _repository.getPermissions();
      
      if (response.success && response.data != null) {
        _availablePermissions = response.data!;
        print('✅ [RolesApiService] Loaded ${_availablePermissions.length} permissions');
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [RolesApiService] Error: $e');
      return (success: false, message: 'Failed to load permissions: $e');
    }
  }

  /// Get role by ID
  Future<({bool success, String? message, RoleModel? role})> getRoleById(String roleId) async {
    print('🔍 [RolesApiService] Getting role: $roleId');
    
    try {
      final response = await _repository.getRoleById(roleId);
      return (success: response.success, message: response.message, role: response.data);
    } catch (e) {
      print('🚨 [RolesApiService] Error: $e');
      return (success: false, message: 'Failed to get role: $e', role: null);
    }
  }

  /// Create new role
  Future<({bool success, String? message, RoleModel? role})> createRole(CreateRoleRequest request) async {
    print('📝 [RolesApiService] Creating role: ${request.name}');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.createRole(request);
      
      if (response.success && response.data != null) {
        _roles.add(response.data!);
        print('✅ [RolesApiService] Role created successfully');
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message, role: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, role: null);
      }
    } catch (e) {
      print('🚨 [RolesApiService] Error: $e');
      _setError('Failed to create role: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to create role: $e', role: null);
    }
  }

  /// Update role
  Future<({bool success, String? message, RoleModel? role})> updateRole(
    String roleId,
    UpdateRoleRequest request,
  ) async {
    print('📝 [RolesApiService] Updating role: $roleId');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateRole(roleId, request);
      
      if (response.success && response.data != null) {
        final index = _roles.indexWhere((r) => r.roleId == roleId);
        if (index != -1) {
          _roles[index] = response.data!;
        }
        print('✅ [RolesApiService] Role updated successfully');
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message, role: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, role: null);
      }
    } catch (e) {
      print('🚨 [RolesApiService] Error: $e');
      _setError('Failed to update role: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to update role: $e', role: null);
    }
  }

  /// Delete role
  Future<({bool success, String? message})> deleteRole(String roleId) async {
    print('🗑️ [RolesApiService] Deleting role: $roleId');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.deleteRole(roleId);
      
      if (response.success) {
        _roles.removeWhere((r) => r.roleId == roleId);
        print('✅ [RolesApiService] Role deleted successfully');
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [RolesApiService] Error: $e');
      _setError('Failed to delete role: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to delete role: $e');
    }
  }

  /// Search roles by name
  List<RoleModel> searchRoles(String query) {
    if (query.isEmpty) return _roles;
    
    final lowerQuery = query.toLowerCase();
    return _roles.where((role) =>
      role.name.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Get permissions grouped by module
  Map<String, List<PermissionModel>> getPermissionsByModule() {
    final Map<String, List<PermissionModel>> grouped = {};
    
    for (final permission in _availablePermissions) {
      grouped.putIfAbsent(permission.module, () => []).add(permission);
    }
    
    return grouped;
  }

  /// Clear data (call on logout)
  void clearData() {
    _roles.clear();
    _availablePermissions.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
