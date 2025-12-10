import 'package:flutter/material.dart';
import '../services/department_service.dart';
import '../models/department_model.dart';

class DepartmentController extends ChangeNotifier {
  final DepartmentService _service = DepartmentService();

  List<Department> _departmentList = [];
  bool _isLoading = false;
  String? _selectedDepartmentId;
  String? _errorMessage;
  bool _isDisposed = false;

  List<Department> get departmentList => _departmentList;
  bool get isLoading => _isLoading;
  String? get selectedDepartmentId => _selectedDepartmentId;
  String? get errorMessage => _errorMessage;

  // Get selected department name
  String? get selectedDepartmentName {
    if (_selectedDepartmentId == null) return null;
    try {
      return _departmentList
          .firstWhere((dept) => dept.id == _selectedDepartmentId)
          .name;
    } catch (e) {
      return null;
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Fetch departments on init
  Future<void> fetchDepartments() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      _departmentList = await _service.getDepartments();
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _safeNotifyListeners();
      debugPrint('Error fetching departments: $e');
    }
  }

  // Set selected department
  void setSelectedDepartment(String? departmentId) {
    _selectedDepartmentId = departmentId;
    _safeNotifyListeners();
  }

  // Clear selected department
  void clearSelectedDepartment() {
    _selectedDepartmentId = null;
    _safeNotifyListeners();
  }

  // Get department by ID
  Department? getDepartmentById(String departmentId) {
    try {
      return _departmentList.firstWhere((dept) => dept.id == departmentId);
    } catch (e) {
      return null;
    }
  }

  // Get error message from exception
  String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}
