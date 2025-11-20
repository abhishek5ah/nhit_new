import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/organization/data/models/organization_api_models.dart';
import 'package:ppv_components/features/organization/data/repositories/organizations_api_repository.dart';
import 'package:ppv_components/core/services/jwt_token_manager.dart';

/// Service layer for organization management with state management
/// Handles tenant isolation and provides reactive updates
class OrganizationsApiService extends ChangeNotifier {
  final OrganizationsApiRepository _repository = OrganizationsApiRepository();
  
  List<OrganizationModel> _organizations = [];
  OrganizationModel? _currentOrganization;
  bool _isLoading = false;
  String? _error;
  String? _currentTenantId;
  final Map<String, List<OrganizationModel>> _childOrganizations = {};
  final Set<String> _childLoadingParents = {};

  // Getters
  List<OrganizationModel> get organizations => _organizations;
  OrganizationModel? get currentOrganization => _currentOrganization;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentTenantId => _currentTenantId;
  bool get hasOrganizations => _organizations.isNotEmpty;
  Map<String, List<OrganizationModel>> get childOrganizations => _childOrganizations;

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

  /// Load organizations for current tenant (TENANT-FILTERED)
  Future<({bool success, String? message})> loadOrganizations() async {
    print('🏢 [OrganizationsApiService] Loading organizations');
    _setLoading(true);
    _setError(null);

    try {
      // Get current tenant ID from JWT token
      final tenantId = await JwtTokenManager.getTenantId();
      if (tenantId == null || tenantId.isEmpty) {
        _setError('No tenant ID found. Please login again.');
        _setLoading(false);
        return (success: false, message: 'No tenant ID found');
      }

      _currentTenantId = tenantId;
      print('🔑 [OrganizationsApiService] Using tenant ID: $tenantId');

      // Fetch tenant-filtered organizations
      final response = await _repository.getOrganizationsByTenant(tenantId);
      
      if (response.success && response.data != null) {
        _organizations = response.data!.organizations;
        
        // Set current organization if we have one stored
        final currentOrgId = await JwtTokenManager.getOrgId();
        if (currentOrgId != null && currentOrgId.isNotEmpty) {
          try {
            _currentOrganization = _organizations.firstWhere(
              (org) => org.orgId == currentOrgId,
            );
          } catch (e) {
            // If stored org not found, use first organization
            _currentOrganization = _organizations.isNotEmpty ? _organizations.first : null;
          }
        } else if (_organizations.isNotEmpty) {
          _currentOrganization = _organizations.first;
        }
        
        print('✅ [OrganizationsApiService] Loaded ${_organizations.length} organizations');
        _setLoading(false);
        return (success: true, message: 'Organizations loaded successfully');
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [OrganizationsApiService] Error loading organizations: $e');
      _setError('Failed to load organizations: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to load organizations: $e');
    }
  }

  /// Get single organization by ID with tenant validation
  Future<({bool success, String? message, OrganizationModel? organization})> getOrganizationById(String orgId) async {
    print('🔍 [OrganizationsApiService] Getting organization by ID: $orgId');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getOrganizationById(orgId);
      
      if (response.success && response.data != null) {
        // Validate tenant access
        final tenantId = await JwtTokenManager.getTenantId();
        if (tenantId != null && !_repository.validateTenantAccess(response.data!, tenantId)) {
          _setError('You don\'t have access to this organization');
          _setLoading(false);
          return (success: false, message: 'Access denied', organization: null);
        }

        print('✅ [OrganizationsApiService] Organization found: ${response.data!.name}');
        _setLoading(false);
        return (success: true, message: 'Organization found', organization: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, organization: null);
      }
    } catch (e) {
      print('🚨 [OrganizationsApiService] Error: $e');
      _setError('Failed to get organization: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to get organization: $e', organization: null);
    }
  }

  /// Create new organization
  Future<({bool success, String? message, OrganizationModel? organization})> createOrganization(CreateOrganizationRequest request) async {
    print('📝 [OrganizationsApiService] Creating organization: ${request.name}');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.createOrganization(request);
      
      if (response.success && response.data != null) {
        print('✅ [OrganizationsApiService] Organization created successfully');
        
        final newOrg = response.data!;
        final parentOrgId = request.parentOrgId;

        if (parentOrgId == null || parentOrgId.isEmpty) {
          // Newly created parent organization becomes default parent for future child creations
          await JwtTokenManager.saveParentOrgId(newOrg.orgId);
        } else {
          // Refresh children for this parent so UI updates instantly
          await loadChildOrganizations(parentOrgId, forceRefresh: true);
        }

        // Reload organizations to include the new one in parent list
        await loadOrganizations();
        
        _setLoading(false);
        return (success: true, message: response.message, organization: newOrg);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, organization: null);
      }
    } catch (e) {
      print('🚨 [OrganizationsApiService] Error: $e');
      _setError('Failed to create organization: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to create organization: $e', organization: null);
    }
  }

  /// Update organization
  Future<({bool success, String? message, OrganizationModel? organization})> updateOrganization(
    String orgId,
    UpdateOrganizationRequest request,
  ) async {
    print('📝 [OrganizationsApiService] Updating organization: $orgId');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.updateOrganization(orgId, request);
      
      if (response.success && response.data != null) {
        print('✅ [OrganizationsApiService] Organization updated successfully');
        
        // Update in local list
        final index = _organizations.indexWhere((org) => org.orgId == orgId);
        if (index != -1) {
          _organizations[index] = response.data!;
        }
        
        // Update current organization if it's the one being edited
        if (_currentOrganization?.orgId == orgId) {
          _currentOrganization = response.data;
        }
        
        _setLoading(false);
        notifyListeners();
        return (success: true, message: response.message, organization: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, organization: null);
      }
    } catch (e) {
      print('🚨 [OrganizationsApiService] Error: $e');
      _setError('Failed to update organization: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to update organization: $e', organization: null);
    }
  }

  /// Switch to a different organization
  Future<({bool success, String? message})> switchOrganization(OrganizationModel organization) async {
    print('🔄 [OrganizationsApiService] Switching to organization: ${organization.name}');

    try {
      _currentOrganization = organization;
      
      // Update stored org ID in JWT token manager
      await JwtTokenManager.saveOrgId(organization.orgId);
      
      notifyListeners();
      print('✅ [OrganizationsApiService] Switched to organization: ${organization.name}');
      return (success: true, message: 'Switched to ${organization.name}');
    } catch (e) {
      print('🚨 [OrganizationsApiService] Error switching organization: $e');
      return (success: false, message: 'Failed to switch organization: $e');
    }
  }

  /// Search organizations by name or code (client-side filtering)
  List<OrganizationModel> searchOrganizations(String query) {
    if (query.isEmpty) return _organizations;
    
    final lowerQuery = query.toLowerCase();
    return _organizations.where((org) =>
      org.name.toLowerCase().contains(lowerQuery) ||
      org.code.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Clear data (call on logout)
  void clearData() {
    _organizations.clear();
    _currentOrganization = null;
    _currentTenantId = null;
    _error = null;
    _isLoading = false;
    _childOrganizations.clear();
    _childLoadingParents.clear();
    notifyListeners();
  }

  /// Load child organizations for a given parent
  Future<({bool success, String? message})> loadChildOrganizations(
    String parentOrgId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _childOrganizations.containsKey(parentOrgId)) {
      return (success: true, message: 'Already loaded');
    }

    if (_childLoadingParents.contains(parentOrgId)) {
      return (success: true, message: 'Already loading');
    }

    _childLoadingParents.add(parentOrgId);

    try {
      final response = await _repository.getChildOrganizations(parentOrgId);
      if (response.success && response.data != null) {
        _childOrganizations[parentOrgId] = response.data!.organizations;
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message ?? 'Failed to load child organizations');
      }
    } catch (e) {
      return (success: false, message: 'Failed to load child organizations: $e');
    } finally {
      _childLoadingParents.remove(parentOrgId);
    }
  }
}
