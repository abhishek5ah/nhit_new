import '../services/project_api_client.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final ProjectApiClient _apiClient = ProjectApiClient();

  /// Get organization with projects by orgId
  Future<OrganizationWithProjectsResponse> getOrganizationWithProjects(String orgId) async {
    try {
      final response = await _apiClient.get('/organizations/$orgId/with-projects');
      
      if (response.statusCode == 200 && response.data != null) {
        return OrganizationWithProjectsResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to fetch organization with projects');
      }
    } catch (e) {
      throw Exception('Error fetching organization with projects: $e');
    }
  }

  /// Get projects list only
  Future<List<Project>> getProjects(String orgId) async {
    try {
      final response = await getOrganizationWithProjects(orgId);
      return response.projects;
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  /// Get project by ID
  Future<Project?> getProjectById(String orgId, String projectId) async {
    try {
      final projects = await getProjects(orgId);
      return projects.firstWhere(
        (project) => project.projectId == projectId,
        orElse: () => throw Exception('Project not found'),
      );
    } catch (e) {
      return null;
    }
  }
}
