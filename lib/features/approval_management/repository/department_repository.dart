import '../services/department_api_client.dart';
import '../models/department_model.dart';

class DepartmentRepository {
  final DepartmentApiClient _apiClient = DepartmentApiClient();

  // Get all departments
  Future<List<Department>> getDepartments() async {
    try {
      final response = await _apiClient.get('/departments');

      if (response.statusCode == 200) {
        final departmentResponse = DepartmentResponse.fromJson(response.data);
        return departmentResponse.departments;
      } else {
        throw Exception('Failed to get departments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching departments: ${e.toString()}');
    }
  }

  // Get department by ID
  Future<Department> getDepartmentById(String departmentId) async {
    try {
      final response = await _apiClient.get('/departments/$departmentId');

      if (response.statusCode == 200) {
        return Department.fromJson(response.data);
      } else {
        throw Exception('Failed to get department: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching department: ${e.toString()}');
    }
  }
}
