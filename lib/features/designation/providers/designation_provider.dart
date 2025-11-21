import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/designation/model/designation_model.dart';
import 'package:ppv_components/features/designation/data/repositories/designation_api_repository.dart';

/// Provider for Designation Management with state management
/// Handles CRUD operations and provides reactive updates
class DesignationProvider extends ChangeNotifier {
  final DesignationApiRepository _repository;

  DesignationProvider({DesignationApiRepository? repository})
      : _repository = repository ?? DesignationApiRepository();

  List<Designation> _designations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Designation> get designations => _designations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDesignations => _designations.isNotEmpty;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Load all designations
  Future<({bool success, String? message})> loadDesignations() async {
    print('📋 [DesignationProvider] Loading designations');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getDesignations();

      if (response.success && response.data != null) {
        _designations = response.data!.designations;
        _sortDesignations();
        print('✅ [DesignationProvider] Loaded ${_designations.length} designations');
        _setLoading(false);
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [DesignationProvider] Error: $e');
      _setError('Failed to load designations: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to load designations: $e');
    }
  }

  /// Get designation by ID
  Future<({bool success, String? message, Designation? designation})>
      getDesignationById(String id) async {
    print('🔍 [DesignationProvider] Getting designation: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getDesignationById(id);

      _setLoading(false);
      if (response.success && response.data != null) {
        return (
          success: true,
          message: response.message,
          designation: response.data
        );
      } else {
        _setError(response.message);
        return (success: false, message: response.message, designation: null);
      }
    } catch (e) {
      print('🚨 [DesignationProvider] Error: $e');
      _setError('Failed to get designation: $e');
      _setLoading(false);
      return (
        success: false,
        message: 'Failed to get designation: $e',
        designation: null
      );
    }
  }

  /// Create new designation
  Future<({bool success, String? message, Designation? designation})>
      createDesignation({
    required String name,
    required String description,
  }) async {
    print('📝 [DesignationProvider] Creating designation: $name');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.createDesignation(
        name: name,
        description: description,
      );

      if (response.success && response.data != null) {
        _designations.add(response.data!);
        _sortDesignations();
        print('✅ [DesignationProvider] Designation created successfully');
        _setLoading(false);
        notifyListeners();
        return (
          success: true,
          message: response.message,
          designation: response.data
        );
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, designation: null);
      }
    } catch (e) {
      print('🚨 [DesignationProvider] Error: $e');
      _setError('Failed to create designation: $e');
      _setLoading(false);
      return (
        success: false,
        message: 'Failed to create designation: $e',
        designation: null
      );
    }
  }

  /// Update designation
  Future<({bool success, String? message, Designation? designation})>
      updateDesignation({
    required String id,
    required String name,
    required String description,
  }) async {
    print('📝 [DesignationProvider] Updating designation: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateDesignation(
        id: id,
        name: name,
        description: description,
      );

      if (response.success && response.data != null) {
        final index = _designations.indexWhere((d) => d.id == id);
        if (index != -1) {
          _designations[index] = response.data!;
        }
        _sortDesignations();
        print('✅ [DesignationProvider] Designation updated successfully');
        _setLoading(false);
        notifyListeners();
        return (
          success: true,
          message: response.message,
          designation: response.data
        );
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, designation: null);
      }
    } catch (e) {
      print('🚨 [DesignationProvider] Error: $e');
      _setError('Failed to update designation: $e');
      _setLoading(false);
      return (
        success: false,
        message: 'Failed to update designation: $e',
        designation: null
      );
    }
  }

  /// Delete designation
  Future<({bool success, String? message})> deleteDesignation(
      String id) async {
    print('🗑️ [DesignationProvider] Deleting designation: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.deleteDesignation(id);

      if (response.success) {
        _designations.removeWhere((d) => d.id == id);
        _sortDesignations();
        print('✅ [DesignationProvider] Designation deleted successfully');
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [DesignationProvider] Error: $e');
      _setError('Failed to delete designation: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to delete designation: $e');
    }
  }

  /// Search designations by name or description
  List<Designation> searchDesignations(String query) {
    if (query.isEmpty) return _designations;

    final lowerQuery = query.toLowerCase();
    return _designations
        .where((desig) =>
            desig.name.toLowerCase().contains(lowerQuery) ||
            desig.description.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Refresh designations (reload from API)
  Future<({bool success, String? message})> refresh() => loadDesignations();

  /// Clear data (call on logout)
  void clearData() {
    _designations.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _sortDesignations() {
    _designations.sort((a, b) {
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
