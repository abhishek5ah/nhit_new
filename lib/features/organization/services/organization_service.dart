import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/organization/data/models/organization_model.dart';
import 'package:ppv_components/features/organization/data/repositories/organization_repository.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';

class OrganizationService extends ChangeNotifier {
  final OrganizationRepository _repository = OrganizationRepository();
  
  List<OrganizationModel> _organizations = [];
  OrganizationModel? _currentOrganization;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<OrganizationModel> get organizations => _organizations;
  OrganizationModel? get currentOrganization => _currentOrganization;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load organizations for current tenant
  Future<({bool success, String? message})> loadOrganizations() async {
    print('🏢 [OrganizationService] Loading organizations');
    _setLoading(true);
    _setError(null);

    try {
      // Get current tenant ID from JWT token
      final tenantId = await JwtTokenManager.getTenantId();
      if (tenantId == null || tenantId.isEmpty) {
        _setError('No tenant ID found');
        return (success: false, message: 'No tenant ID found');
      }

      final response = await _repository.getOrganizations(tenantId);
      
      if (response.success && response.data != null) {
        _organizations = response.data!.organizations;
        
        // Set current organization if we have one stored
        final currentOrgId = await JwtTokenManager.getOrgId();
        if (currentOrgId != null && currentOrgId.isNotEmpty) {
          _currentOrganization = _organizations.firstWhere(
            (org) => org.orgId == currentOrgId,
            orElse: () => _organizations.isNotEmpty ? _organizations.first : throw StateError('No organizations found'),
          );
        } else if (_organizations.isNotEmpty) {
          _currentOrganization = _organizations.first;
        }
        
        print('✅ [OrganizationService] Loaded ${_organizations.length} organizations');
        return (success: true, message: 'Organizations loaded successfully');
      } else {
        _setError(response.message);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [OrganizationService] Error loading organizations: $e');
      _setError('Failed to load organizations: $e');
      return (success: false, message: 'Failed to load organizations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Switch to a different organization
  Future<({bool success, String? message})> switchOrganization(OrganizationModel organization) async {
    print('🔄 [OrganizationService] Switching to organization: ${organization.name}');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.switchOrganization(organization.orgId);
      
      if (response.success) {
        _currentOrganization = organization;
        
        // Update stored org ID in JWT token manager
        await JwtTokenManager.saveOrgId(organization.orgId);
        
        print('✅ [OrganizationService] Switched to organization: ${organization.name}');
        return (success: true, message: 'Switched to ${organization.name}');
      } else {
        _setError(response.message);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [OrganizationService] Error switching organization: $e');
      _setError('Failed to switch organization: $e');
      return (success: false, message: 'Failed to switch organization: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update organization
  Future<({bool success, String? message})> updateOrganization(
    String orgId,
    UpdateOrganizationRequest request,
  ) async {
    print('📝 [OrganizationService] Updating organization: $orgId');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateOrganization(orgId, request);
      
      if (response.success) {
        // Reload organizations to get updated data
        await loadOrganizations();
        
        print('✅ [OrganizationService] Organization updated successfully');
        return (success: true, message: 'Organization updated successfully');
      } else {
        _setError(response.message);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [OrganizationService] Error updating organization: $e');
      _setError('Failed to update organization: $e');
      return (success: false, message: 'Failed to update organization: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get organization by code
  Future<({bool success, String? message, OrganizationModel? organization})> getOrganizationByCode(String code) async {
    print('🔍 [OrganizationService] Getting organization by code: $code');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getOrganizationByCode(code);
      
      if (response.success && response.data != null) {
        print('✅ [OrganizationService] Organization found: ${response.data!.name}');
        return (success: true, message: 'Organization found', organization: response.data);
      } else {
        _setError(response.message);
        return (success: false, message: response.message, organization: null);
      }
    } catch (e) {
      print('🚨 [OrganizationService] Error getting organization: $e');
      _setError('Failed to get organization: $e');
      return (success: false, message: 'Failed to get organization: $e', organization: null);
    } finally {
      _setLoading(false);
    }
  }

  // Clear data (call on logout)
  void clearData() {
    _organizations.clear();
    _currentOrganization = null;
    _error = null;
    notifyListeners();
  }
}

// Global instance
final organizationService = OrganizationService();
