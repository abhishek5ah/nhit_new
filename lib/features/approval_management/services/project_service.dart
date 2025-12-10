import '../repository/project_repository.dart';
import '../models/project_model.dart';

class ProjectService {
  final ProjectRepository _repository = ProjectRepository();

  /// Get all projects for an organization
  Future<List<Project>> getProjects(String orgId) async {
    try {
      return await _repository.getProjects(orgId);
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Get organization with projects
  Future<OrganizationWithProjectsResponse> getOrganizationWithProjects(String orgId) async {
    try {
      return await _repository.getOrganizationWithProjects(orgId);
    } catch (e) {
      throw Exception('Failed to fetch organization with projects: $e');
    }
  }

  /// Get project by ID
  Future<Project?> getProjectById(String orgId, String projectId) async {
    try {
      return await _repository.getProjectById(orgId, projectId);
    } catch (e) {
      return null;
    }
  }
}
