// ============================================================================
// USER MAPPER
// Converts API models to legacy UI models for compatibility
// ============================================================================

import 'package:ppv_components/features/user/data/models/user_api_models.dart';
import 'package:ppv_components/features/user/model/user_model.dart';

/// Maps UserApiModel to legacy User model for UI compatibility
User mapUserApiToUi(UserApiModel apiModel) {
  return User(
    id: apiModel.userId.hashCode, // Convert UUID to int for legacy model
    name: apiModel.name,
    username: apiModel.email.split('@').first, // Derive username from email
    email: apiModel.email,
    roles: apiModel.roles,
    isActive: true, // Assume active if user exists
    designation: apiModel.designationName,
    department: apiModel.departmentName,
    signatureUrl: apiModel.signatureUrl,
    employeeId: apiModel.userId, // Use userId as employeeId
    contactNumber: null, // Not available in API model
    accountHolder: apiModel.accountHolderName,
    bankName: apiModel.bankName,
    bankAccount: apiModel.bankAccountNumber,
    ifsc: apiModel.ifscCode,
  );
}

/// Maps list of UserApiModel to list of legacy User models
List<User> mapUserApiListToUi(List<UserApiModel> apiModels) {
  return apiModels.map(mapUserApiToUi).toList();
}
