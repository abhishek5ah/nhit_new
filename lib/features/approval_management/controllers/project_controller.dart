import 'package:flutter/material.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';
import '../services/project_service.dart';
import '../models/project_model.dart';

class ProjectController extends ChangeNotifier {
  final ProjectService _service = ProjectService();

  List<Project> _projectList = [];
  bool _isLoading = false;
  String? _selectedProjectId;
  String? _errorMessage;
  OrganizationData? _organizationData;

  List<Project> get projectList => _projectList;
  bool get isLoading => _isLoading;
  String? get selectedProjectId => _selectedProjectId;
  String? get errorMessage => _errorMessage;
  OrganizationData? get organizationData => _organizationData;

  /// Get selected project name
  String? get selectedProjectName {
    if (_selectedProjectId == null) return null;
    try {
      return _projectList
          .firstWhere((project) => project.projectId == _selectedProjectId)
          .projectName;
    } catch (e) {
      return null;
    }
  }

  /// Fetch projects on init
  Future<void> fetchProjects() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get orgId from secure storage
      final orgId = await JwtTokenManager.getOrgId();
      
      if (orgId == null || orgId.isEmpty) {
        throw Exception('Organization ID not found. Please login again.');
      }

      final response = await _service.getOrganizationWithProjects(orgId);
      _organizationData = response.organization;
      _projectList = response.projects;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      debugPrint('Error fetching projects: $e');
    }
  }

  /// Set selected project
  void setSelectedProject(String? projectId) {
    _selectedProjectId = projectId;
    notifyListeners();
  }

  /// Clear selected project
  void clearSelectedProject() {
    _selectedProjectId = null;
    notifyListeners();
  }

  /// Get project by ID
  Project? getProjectById(String projectId) {
    try {
      return _projectList.firstWhere((project) => project.projectId == projectId);
    } catch (e) {
      return null;
    }
  }

  /// Get error message from exception
  String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  /// Check if projects list is empty
  bool get hasProjects => _projectList.isNotEmpty;

  /// Get projects count
  int get projectsCount => _projectList.length;
}
