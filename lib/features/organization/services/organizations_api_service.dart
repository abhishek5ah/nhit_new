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

  /// Load organizations for the logged-in user's parent org hierarchy.
  Future<({bool success, String? message})> loadOrganizations() async {
    print('🏢 [OrganizationsApiService] Loading organizations');
    _setLoading(true);
    _setError(null);

    try {
      final parentOrgId = await JwtTokenManager.getParentOrgId();

      if (parentOrgId != null && parentOrgId.isNotEmpty) {
        print('🌿 [OrganizationsApiService] Loading child orgs for parent: $parentOrgId');
        print('🔗 [OrganizationsApiService] API Call: GET /organizations/$parentOrgId/children');
        final childResponse = await _repository.getChildOrganizations(parentOrgId);

        if (childResponse.success && childResponse.data != null) {
          _organizations = childResponse.data!.organizations;
          _currentOrganization = _organizations.isNotEmpty ? _organizations.first : null;
          _childOrganizations[parentOrgId] = _organizations;
          
          print('📊 [OrganizationsApiService] Child orgs loaded: ${_organizations.length} organizations');
          
          // Log missing data statistics
          _logMissingDataStats(_organizations, 'child organizations');
          
          // Run detailed tenant analysis for debugging
          debugTenantDataPatterns();
          
          _setLoading(false);
          return (success: true, message: childResponse.message);
        } else {
          _setError(childResponse.message ?? 'Failed to load child organizations');
          _setLoading(false);
          return (success: false, message: childResponse.message);
        }
      }

      // Fallback: tenant-filtered fetch (legacy support)
      final tenantId = await JwtTokenManager.getTenantId();
      if (tenantId == null || tenantId.isEmpty) {
        _setError('No tenant ID found. Please login again.');
        _setLoading(false);
        return (success: false, message: 'No tenant ID found');
      }

      _currentTenantId = tenantId;
      print('🔑 [OrganizationsApiService] Falling back to tenant ID: $tenantId');
      print('🔗 [OrganizationsApiService] API Call: GET /tenants/$tenantId/organizations');

      final response = await _repository.getOrganizationsByTenant(tenantId);
      if (response.success && response.data != null) {
        _organizations = response.data!.organizations;

        final currentOrgId = await JwtTokenManager.getOrgId();
        if (currentOrgId != null && currentOrgId.isNotEmpty) {
          try {
            _currentOrganization = _organizations.firstWhere((org) => org.orgId == currentOrgId);
          } catch (e) {
            _currentOrganization = _organizations.isNotEmpty ? _organizations.first : null;
          }
        } else if (_organizations.isNotEmpty) {
          _currentOrganization = _organizations.first;
        }

        // Log missing data statistics
        _logMissingDataStats(_organizations, 'tenant organizations');
        
        // Run detailed tenant analysis for debugging
        debugTenantDataPatterns();

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
    print('🏢 [OrganizationsApiService] Creating organization: ${request.name}');
    print('📦 [OrganizationsApiService] Request JSON: ${request.toJson()}');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.createOrganization(request);
      
      print('📝 [OrganizationsApiService] API Response:');
      print('   Success: ${response.success}');
      print('   Message: ${response.message}');
      print('   Data: ${response.data?.toJson()}');
      
      if (response.success && response.data != null) {
        final newOrg = response.data!;
        
        // Log the returned organization data
        print('🔍 [OrganizationsApiService] Created organization analysis:');
        print('   Name: ${newOrg.name}');
        print('   SuperAdmin: ${newOrg.superAdmin != null ? 'PRESENT (${newOrg.superAdmin!.name})' : 'NULL'}');
        print('   CreatedBy: ${newOrg.createdBy?.isNotEmpty == true ? '"${newOrg.createdBy}"' : 'EMPTY/NULL'}');
        print('   ParentOrgId: ${newOrg.parentOrgId}');
        print('   TenantId: ${newOrg.tenantId}');
        
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

  /// Log statistics about missing superAdmin and createdBy data
  void _logMissingDataStats(List<OrganizationModel> orgs, String source) {
    if (orgs.isEmpty) return;

    final missingSuper = orgs.where((org) => org.superAdmin == null).length;
    final missingCreatedBy = orgs.where((org) => org.isMissingCreatedBy).length;
    final incompleteAdmin = orgs.where((org) => !org.hasCompleteAdminData).length;
    
    // Get unique tenant IDs for analysis
    final tenantIds = orgs.map((org) => org.tenantId).toSet();
    
    print('\n📊 [OrganizationsApiService] === DATA INTEGRITY REPORT ===');
    print('📁 Source: $source');
    print('🏢 Total organizations: ${orgs.length}');
    print('🔑 Unique tenants: ${tenantIds.length} (${tenantIds.join(', ')})');
    print('🚫 Missing superAdmin: $missingSuper/${orgs.length} (${(missingSuper / orgs.length * 100).toStringAsFixed(1)}%)');
    print('🚫 Missing createdBy: $missingCreatedBy/${orgs.length} (${(missingCreatedBy / orgs.length * 100).toStringAsFixed(1)}%)');
    print('⚠️ Incomplete admin data: $incompleteAdmin/${orgs.length} (${(incompleteAdmin / orgs.length * 100).toStringAsFixed(1)}%)');
    
    // Tenant-specific analysis
    for (final tenantId in tenantIds) {
      final tenantOrgs = orgs.where((org) => org.tenantId == tenantId).toList();
      final tenantMissingSuper = tenantOrgs.where((org) => org.superAdmin == null).length;
      final tenantMissingCreated = tenantOrgs.where((org) => org.isMissingCreatedBy).length;
      
      print('\n🏫 Tenant $tenantId:');
      print('   Organizations: ${tenantOrgs.length}');
      print('   Missing superAdmin: $tenantMissingSuper/${tenantOrgs.length}');
      print('   Missing createdBy: $tenantMissingCreated/${tenantOrgs.length}');
      
      if (tenantMissingSuper > 0 || tenantMissingCreated > 0) {
        print('   ❌ PROBLEMATIC TENANT - Missing data detected!');
      } else {
        print('   ✅ HEALTHY TENANT - All data complete');
      }
    }
      
    // List specific organizations with missing data
    final problematicOrgs = orgs.where((org) => org.isMissingCreatedBy || org.superAdmin == null).toList();
    if (problematicOrgs.isNotEmpty) {
      print('\n🔍 Organizations with missing data:');
      for (final org in problematicOrgs.take(8)) { // Show more for debugging
        print('   - ${org.name} (${org.code}) [Tenant: ${org.tenantId.substring(0, 8)}...]:');
        print('     SuperAdmin: ${org.superAdmin != null ? 'PRESENT' : 'NULL'}');
        print('     CreatedBy: ${org.createdBy?.isNotEmpty == true ? '"${org.createdBy}"' : 'EMPTY/NULL'}');
      }
      if (problematicOrgs.length > 8) {
        print('   ... and ${problematicOrgs.length - 8} more');
      }
    } else {
      print('\n✅ All $source have complete admin data - NO ISSUES DETECTED');
    }
    
    print('=== END DATA INTEGRITY REPORT ===\n');
  }
  
  /// Debug method to analyze tenant-specific data patterns
  void debugTenantDataPatterns() async {
    if (_organizations.isEmpty) {
      print('🔍 [DEBUG] No organizations loaded for analysis');
      return;
    }
    
    print('\n🔬 [DEBUG] === TENANT DATA PATTERN ANALYSIS ===');
    
    final tenantGroups = <String, List<OrganizationModel>>{};
    for (final org in _organizations) {
      tenantGroups.putIfAbsent(org.tenantId, () => []).add(org);
    }
    
    for (final entry in tenantGroups.entries) {
      final tenantId = entry.key;
      final orgs = entry.value;
      
      print('\n🏫 Tenant: $tenantId');
      print('   Organizations: ${orgs.length}');
      
      // Check creation patterns
      final withSuperAdmin = orgs.where((org) => org.superAdmin != null).length;
      final withCreatedBy = orgs.where((org) => org.createdBy?.isNotEmpty == true).length;
      final creationDates = orgs.map((org) => org.createdAt.toIso8601String().substring(0, 10)).toSet();
      
      print('   SuperAdmin data: $withSuperAdmin/${orgs.length}');
      print('   CreatedBy data: $withCreatedBy/${orgs.length}');
      print('   Creation dates: ${creationDates.join(', ')}');
      
      // Sample organization details
      if (orgs.isNotEmpty) {
        final sample = orgs.first;
        print('   Sample org: ${sample.name}');
        print('   Sample superAdmin: ${sample.superAdmin?.name ?? 'NULL'}');
        print('   Sample createdBy: "${sample.createdBy ?? 'NULL'}"');
      }
      
      // Identify potential issues
      if (withSuperAdmin == 0 && withCreatedBy == 0) {
        print('   🔴 CRITICAL: All organizations missing admin data!');
      } else if (withSuperAdmin < orgs.length || withCreatedBy < orgs.length) {
        print('   🟡 WARNING: Partial admin data missing');
      } else {
        print('   🟢 HEALTHY: Complete admin data');
      }
    }
    
    print('=== END TENANT ANALYSIS ===\n');
  }
}
