import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/department/model/department_model.dart';
import 'package:ppv_components/features/department/data/repositories/department_api_repository.dart';

/// Provider for Department Management with state management
/// Handles CRUD operations and provides reactive updates
class DepartmentProvider extends ChangeNotifier {
  final DepartmentApiRepository _repository;

  DepartmentProvider({DepartmentApiRepository? repository})
      : _repository = repository ?? DepartmentApiRepository();

  List<Department> _departments = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Department> get departments => _departments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDepartments => _departments.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Load all departments
  Future<({bool success, String? message})> loadDepartments() async {
    print('📋 [DepartmentProvider] Loading departments');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getDepartments();

      if (response.success && response.data != null) {
        _departments = response.data!.departments;
        _sortDepartments();
        print('✅ [DepartmentProvider] Loaded ${_departments.length} departments');
        _setLoading(false);
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [DepartmentProvider] Error: $e');
      _setError('Failed to load departments: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to load departments: $e');
    }
  }

  /// Create new department
  Future<({bool success, String? message, Department? department})>
      createDepartment({
    required String name,
    required String description,
  }) async {
    print('📝 [DepartmentProvider] Creating department: $name');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.createDepartment(
        name: name,
        description: description,
      );

      if (response.success && response.data != null) {
        _departments.add(response.data!);
        _sortDepartments();
        print('✅ [DepartmentProvider] Department created successfully');
        _setLoading(false);
        notifyListeners();
        return (
          success: true,
          message: response.message,
          department: response.data
        );
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, department: null);
      }
    } catch (e) {
      print('🚨 [DepartmentProvider] Error: $e');
      _setError('Failed to create department: $e');
      _setLoading(false);
      return (
        success: false,
        message: 'Failed to create department: $e',
        department: null
      );
    }
  }

  /// Update department
  Future<({bool success, String? message, Department? department})>
      updateDepartment({
    required String id,
    required String name,
    required String description,
  }) async {
    print('📝 [DepartmentProvider] Updating department: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateDepartment(
        id: id,
        name: name,
        description: description,
      );

      if (response.success && response.data != null) {
        final index = _departments.indexWhere((d) => d.id == id);
        if (index != -1) {
          _departments[index] = response.data!;
        }
        _sortDepartments();
        print('✅ [DepartmentProvider] Department updated successfully');
        _setLoading(false);
        notifyListeners();
        return (
          success: true,
          message: response.message,
          department: response.data
        );
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, department: null);
      }
    } catch (e) {
      print('🚨 [DepartmentProvider] Error: $e');
      _setError('Failed to update department: $e');
      _setLoading(false);
      return (
        success: false,
        message: 'Failed to update department: $e',
        department: null
      );
    }
  }

  /// Delete department
  Future<({bool success, String? message})> deleteDepartment(
      String id) async {
    print('🗑️ [DepartmentProvider] Deleting department: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.deleteDepartment(id);

      if (response.success) {
        _departments.removeWhere((d) => d.id == id);
        _sortDepartments();
        print('✅ [DepartmentProvider] Department deleted successfully');
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [DepartmentProvider] Error: $e');
      _setError('Failed to delete department: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to delete department: $e');
    }
  }

  /// Search departments by name or description
  List<Department> searchDepartments(String query) {
    if (query.isEmpty) return _departments;

    final lowerQuery = query.toLowerCase();
    return _departments
        .where((dept) =>
            dept.name.toLowerCase().contains(lowerQuery) ||
            dept.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Refresh departments (reload from API)
  Future<({bool success, String? message})> refresh() => loadDepartments();

  /// Clear data (call on logout)
  void clearData() {
    _departments.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _sortDepartments() {
    _departments.sort((a, b) {
      final aTime = a.createdAt ?? a.updatedAt;
      final bTime = b.createdAt ?? b.updatedAt;

      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime); // Newest first
      } else if (aTime != null) {
        return -1;
      } else if (bTime != null) {
        return 1;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }
}
