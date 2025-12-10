import '../repository/department_repository.dart';
import '../models/department_model.dart';

class DepartmentService {
  final DepartmentRepository _repository = DepartmentRepository();

  // Get all departments
  Future<List<Department>> getDepartments() async {
    try {
      return await _repository.getDepartments();
    } catch (e) {
      throw Exception('Failed to get departments: ${e.toString()}');
    }
  }

  // Get department by ID
  Future<Department> getDepartmentById(String departmentId) async {
    try {
      return await _repository.getDepartmentById(departmentId);
    } catch (e) {
      throw Exception('Failed to get department: ${e.toString()}');
    }
  }
}
