/// Project Model for Approval Management
/// Represents a project with ID and name
class Project {
  final String projectId;
  final String projectName;

  Project({
    required this.projectId,
    required this.projectName,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      projectId: json['projectId'] as String? ?? json['project_id'] as String? ?? '',
      projectName: json['projectName'] as String? ?? json['project_name'] as String? ?? json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'projectName': projectName,
    };
  }

  @override
  String toString() => 'Project(projectId: $projectId, projectName: $projectName)';
}

/// Organization with Projects Response
class OrganizationWithProjectsResponse {
  final OrganizationData organization;
  final List<Project> projects;

  OrganizationWithProjectsResponse({
    required this.organization,
    required this.projects,
  });

  factory OrganizationWithProjectsResponse.fromJson(Map<String, dynamic> json) {
    return OrganizationWithProjectsResponse(
      organization: OrganizationData.fromJson(json['organization'] as Map<String, dynamic>),
      projects: (json['projects'] as List<dynamic>?)
          ?.map((item) => Project.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': organization.toJson(),
      'projects': projects.map((p) => p.toJson()).toList(),
    };
  }
}

/// Organization Data
class OrganizationData {
  final String orgId;
  final String name;
  final List<String> initialProjects;

  OrganizationData({
    required this.orgId,
    required this.name,
    required this.initialProjects,
  });

  factory OrganizationData.fromJson(Map<String, dynamic> json) {
    return OrganizationData(
      orgId: json['orgId'] as String? ?? json['org_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      initialProjects: (json['initialProjects'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orgId': orgId,
      'name': name,
      'initialProjects': initialProjects,
    };
  }
}
