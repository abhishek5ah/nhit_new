import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/roles/data/models/role_models.dart';
import 'package:ppv_components/features/roles/data/repositories/roles_api_repository.dart';

/// Provider for listing roles (table view)
class RoleListProvider extends ChangeNotifier {
  final IRolesApiRepository _repository;

  RoleListProvider({IRolesApiRepository? repository})
      : _repository = repository ?? RolesApiRepository();

  List<RoleModel> _roles = [];
  bool _isLoading = false;
  String? _error;

  List<RoleModel> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasRoles => _roles.isNotEmpty;

  Future<void> loadRoles() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getRoles();
      if (response.success && response.data != null) {
        _roles = response.data!.roles;
      } else {
        _setError(response.message);
      }
    } catch (e) {
      _setError('Failed to load roles: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadRoles();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }
}

/// Provider for permissions list and grouping
class PermissionProvider extends ChangeNotifier {
  final IRolesApiRepository _repository;

  PermissionProvider({IRolesApiRepository? repository})
      : _repository = repository ?? RolesApiRepository();

  List<PermissionModel> _permissions = [];
  bool _isLoading = false;
  String? _error;

  List<PermissionModel> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPermissions => _permissions.isNotEmpty;

  Map<String, List<PermissionModel>> get permissionsByModule {
    final Map<String, List<PermissionModel>> grouped = {};
    for (final permission in _permissions) {
      grouped.putIfAbsent(permission.module, () => []).add(permission);
    }
    return grouped;
  }

  Future<void> loadPermissions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getPermissions();
      if (response.success && response.data != null) {
        _permissions = response.data!;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load permissions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Provider for viewing a single role
class RoleDetailProvider extends ChangeNotifier {
  final IRolesApiRepository _repository;

  RoleDetailProvider({IRolesApiRepository? repository})
      : _repository = repository ?? RolesApiRepository();

  RoleModel? _role;
  bool _isLoading = false;
  String? _error;

  RoleModel? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRole(String roleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getRoleById(roleId);
      if (response.success && response.data != null) {
        _role = response.data;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load role: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// Provider for creating a role
class RoleCreateProvider extends ChangeNotifier {
  final IRolesApiRepository _repository;

  RoleCreateProvider({IRolesApiRepository? repository})
      : _repository = repository ?? RolesApiRepository();

  bool _isSubmitting = false;
  String? _error;
  RoleModel? _createdRole;

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  RoleModel? get createdRole => _createdRole;

  Future<bool> createRole({
    required String name,
    required List<String> permissions,
  }) async {
    _isSubmitting = true;
    _error = null;
    _createdRole = null;
    notifyListeners();

    try {
      final request = CreateRoleRequest(name: name, permissions: permissions);
      final response = await _repository.createRole(request);
      if (response.success && response.data != null) {
        _createdRole = response.data;
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to create role: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}

/// Provider for editing an existing role
class RoleEditProvider extends ChangeNotifier {
  final IRolesApiRepository _repository;

  RoleEditProvider({IRolesApiRepository? repository})
      : _repository = repository ?? RolesApiRepository();

  RoleModel? _role;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Local selection state for permissions
  final Set<String> _selectedPermissions = {};

  RoleModel? get role => _role;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  Set<String> get selectedPermissions => _selectedPermissions;

  Future<void> loadRole(String roleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _repository.getRoleById(roleId);
      if (response.success && response.data != null) {
        _role = response.data;
        _selectedPermissions
          ..clear()
          ..addAll(response.data!.permissions);
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Failed to load role: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePermission(String permissionName) {
    if (_selectedPermissions.contains(permissionName)) {
      _selectedPermissions.remove(permissionName);
    } else {
      _selectedPermissions.add(permissionName);
    }
    notifyListeners();
  }

  Future<bool> saveChanges() async {
    if (_role == null) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final request = UpdateRoleRequest(
        name: _role!.name,
        permissions: _selectedPermissions.toList(),
      );

      final response = await _repository.updateRole(_role!.roleId!, request);
      if (response.success && response.data != null) {
        _role = response.data;
        _selectedPermissions
          ..clear()
          ..addAll(response.data!.permissions);
        _isSaving = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message;
        _isSaving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to update role: $e';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
