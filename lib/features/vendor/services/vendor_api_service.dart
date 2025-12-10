import 'package:flutter/foundation.dart';
import 'package:ppv_components/features/vendor/data/models/vendor_api_models.dart';
import 'package:ppv_components/features/vendor/data/repositories/vendor_api_repository.dart';

/// Service layer for vendor management with state management
/// Handles all vendor and banking operations with reactive updates
class VendorApiService extends ChangeNotifier {
  final VendorApiRepository _repository = VendorApiRepository();

  List<VendorApiModel> _vendors = [];
  VendorApiModel? _currentVendor;
  VendorPagination? _pagination;
  bool _isLoading = false;
  String? _error;
  List<String> _projectDropdowns = [];
  bool _isProjectLoading = false;
  String? _projectsError;

  // Getters
  List<VendorApiModel> get vendors => _vendors;
  VendorApiModel? get currentVendor => _currentVendor;
  VendorPagination? get pagination => _pagination;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get projectDropdowns => _projectDropdowns;
  bool get isProjectLoading => _isProjectLoading;
  String? get projectsError => _projectsError;
  bool get hasVendors => _vendors.isNotEmpty;

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

  void _setProjectLoading(bool loading) {
    _isProjectLoading = loading;
    notifyListeners();
  }

  void _setProjectsError(String? error) {
    _projectsError = error;
    notifyListeners();
  }

  /// Load vendors with optional filters
  Future<({bool success, String? message})> loadVendors({
    int page = 1,
    int perPage = 10,
    String? status,
    String? search,
    String? vendorType,
    bool forceRefresh = false,
  }) async {
    print('🏢 [VendorApiService] Loading vendors - Page: $page');
    
    if (!forceRefresh && _vendors.isNotEmpty && page == (_pagination?.page ?? 1)) {
      return (success: true, message: 'Vendors already loaded');
    }

    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.listVendors(
        page: page,
        perPage: perPage,
        status: status,
        search: search,
        vendorType: vendorType,
      );

      if (response.success && response.data != null) {
        _vendors = response.data!.vendors;
        _pagination = response.data!.pagination;
        print('✅ [VendorApiService] Loaded ${_vendors.length} vendors');
        _setLoading(false);
        return (success: true, message: 'Vendors loaded successfully');
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error loading vendors: $e');
      _setError('Failed to load vendors: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to load vendors: $e');
    }
  }

  /// Get vendor by ID
  Future<({bool success, String? message, VendorApiModel? vendor})> getVendorById(int id) async {
    print('🔍 [VendorApiService] Getting vendor by ID: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getVendorById(id);

      if (response.success && response.data != null) {
        _currentVendor = response.data;
        print('✅ [VendorApiService] Vendor found: ${response.data!.name}');
        _setLoading(false);
        return (success: true, message: 'Vendor found', vendor: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, vendor: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      _setError('Failed to get vendor: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to get vendor: $e', vendor: null);
    }
  }

  /// Get vendor by code
  Future<({bool success, String? message, VendorApiModel? vendor})> getVendorByCode(String code) async {
    print('🔍 [VendorApiService] Getting vendor by code: $code');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.getVendorByCode(code);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Vendor found: ${response.data!.name}');
        _setLoading(false);
        return (success: true, message: 'Vendor found', vendor: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, vendor: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      _setError('Failed to get vendor: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to get vendor: $e', vendor: null);
    }
  }

  /// Create new vendor
  Future<({bool success, String? message, VendorApiModel? vendor})> createVendor(
      VendorApiModel vendor) async {
    print('🏢 [VendorApiService] Creating vendor: ${vendor.name}');
    _setLoading(true);
    _setError(null);

    try {
      final request = CreateVendorRequest(vendor: vendor);
      final response = await _repository.createVendor(request);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Vendor created successfully');
        
        // Reload vendors to include the new one
        await loadVendors(forceRefresh: true);
        
        _setLoading(false);
        return (success: true, message: response.message, vendor: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, vendor: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      _setError('Failed to create vendor: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to create vendor: $e', vendor: null);
    }
  }

  /// Update vendor
  Future<({bool success, String? message, VendorApiModel? vendor})> updateVendor(
      int id, VendorApiModel vendor) async {
    print('📝 [VendorApiService] Updating vendor: $id');
    _setLoading(true);
    _setError(null);

    try {
      final request = UpdateVendorRequest(id: id, vendor: vendor);
      final response = await _repository.updateVendor(request);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Vendor updated successfully');
        
        // Update in local list
        final index = _vendors.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vendors[index] = response.data!;
        }
        
        if (_currentVendor?.id == id) {
          _currentVendor = response.data;
        }
        
        notifyListeners();
        _setLoading(false);
        return (success: true, message: response.message, vendor: response.data);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message, vendor: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      _setError('Failed to update vendor: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to update vendor: $e', vendor: null);
    }
  }

  /// Delete vendor
  Future<({bool success, String? message})> deleteVendor(int id) async {
    print('🗑️ [VendorApiService] Deleting vendor: $id');
    _setLoading(true);
    _setError(null);

    try {
      final response = await _repository.deleteVendor(id);

      if (response.success) {
        print('✅ [VendorApiService] Vendor deleted successfully');
        
        // Remove from local list
        _vendors.removeWhere((v) => v.id == id);
        
        if (_currentVendor?.id == id) {
          _currentVendor = null;
        }
        
        notifyListeners();
        _setLoading(false);
        return (success: true, message: response.message);
      } else {
        _setError(response.message);
        _setLoading(false);
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      _setError('Failed to delete vendor: $e');
      _setLoading(false);
      return (success: false, message: 'Failed to delete vendor: $e');
    }
  }

  /// Generate vendor code
  Future<({bool success, String? message, String? code})> generateVendorCode({
    required String prefix,
    required String vendorName,
  }) async {
    print(
        '🔢 [VendorApiService] Generating vendor code - prefix: $prefix, name: $vendorName');

    try {
      final response = await _repository.generateVendorCode(
        prefix: prefix,
        vendorName: vendorName,
      );

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Vendor code generated: ${response.data}');
        return (success: true, message: response.message, code: response.data);
      } else {
        return (success: false, message: response.message, code: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to generate code: $e', code: null);
    }
  }

  /// Load project dropdowns
  Future<({bool success, String? message, List<String> projects})> loadProjectDropdowns({bool forceRefresh = false}) async {
    print('📁 [VendorApiService] Loading project dropdowns');

    if (!forceRefresh && _projectDropdowns.isNotEmpty) {
      return (success: true, message: 'Projects already loaded', projects: _projectDropdowns);
    }

    _setProjectLoading(true);
    _setProjectsError(null);

    try {
      final response = await _repository.getProjectDropdowns();

      if (response.success && response.data != null) {
        _projectDropdowns = response.data!;
        _setProjectLoading(false);
        notifyListeners();
        return (success: true, message: response.message, projects: _projectDropdowns);
      } else {
        _setProjectsError(response.message);
        _setProjectLoading(false);
        return (success: false, message: response.message, projects: const <String>[]);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error loading projects: $e');
      _setProjectsError('Failed to load projects: $e');
      _setProjectLoading(false);
      return (success: false, message: 'Failed to load projects: $e', projects: const <String>[]);
    }
  }

  /// Update vendor code
  Future<({bool success, String? message})> updateVendorCode(int id, String code) async {
    print('🔢 [VendorApiService] Updating vendor code: $id');

    try {
      final request = UpdateVendorCodeRequest(id: id, vendorCode: code);
      final response = await _repository.updateVendorCode(request);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Vendor code updated successfully');
        
        // Update in local list
        final index = _vendors.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vendors[index] = response.data!;
        }
        
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to update code: $e');
    }
  }

  /// Regenerate vendor code
  Future<({bool success, String? message})> regenerateVendorCode(int id, String prefix) async {
    print('🔄 [VendorApiService] Regenerating vendor code: $id');

    try {
      final request = RegenerateVendorCodeRequest(id: id, prefix: prefix);
      final response = await _repository.regenerateVendorCode(request);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Vendor code regenerated successfully');
        
        // Update in local list
        final index = _vendors.indexWhere((v) => v.id == id);
        if (index != -1) {
          _vendors[index] = response.data!;
        }
        
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to regenerate code: $e');
    }
  }

  // ============ BANK ACCOUNT OPERATIONS ============

  /// Create vendor bank account
  Future<({bool success, String? message, VendorBankAccount? account})> createVendorAccount(
      int vendorId, VendorBankAccount account) async {
    print('🏦 [VendorApiService] Creating bank account for vendor: $vendorId');

    try {
      final request = CreateVendorAccountRequest(vendorId: vendorId, account: account);
      final response = await _repository.createVendorAccount(request);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Bank account created successfully');
        
        // Update vendor in local list
        final index = _vendors.indexWhere((v) => v.id == vendorId);
        if (index != -1) {
          final updatedAccounts = List<VendorBankAccount>.from(_vendors[index].accounts)
            ..add(response.data!);
          _vendors[index] = VendorApiModel(
            id: _vendors[index].id,
            vendorCode: _vendors[index].vendorCode,
            name: _vendors[index].name,
            contactPerson: _vendors[index].contactPerson,
            email: _vendors[index].email,
            phone: _vendors[index].phone,
            alternatePhone: _vendors[index].alternatePhone,
            address: _vendors[index].address,
            gstNumber: _vendors[index].gstNumber,
            panNumber: _vendors[index].panNumber,
            tanNumber: _vendors[index].tanNumber,
            msmeRegistered: _vendors[index].msmeRegistered,
            msmeNumber: _vendors[index].msmeNumber,
            vendorType: _vendors[index].vendorType,
            paymentTerms: _vendors[index].paymentTerms,
            creditLimit: _vendors[index].creditLimit,
            status: _vendors[index].status,
            accounts: updatedAccounts,
            createdAt: _vendors[index].createdAt,
            updatedAt: _vendors[index].updatedAt,
          );
        }
        
        notifyListeners();
        return (success: true, message: response.message, account: response.data);
      } else {
        return (success: false, message: response.message, account: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to create account: $e', account: null);
    }
  }

  /// Get vendor bank accounts
  Future<({bool success, String? message, List<VendorBankAccount>? accounts})> getVendorAccounts(
      int vendorId) async {
    print('🏦 [VendorApiService] Getting bank accounts for vendor: $vendorId');

    try {
      final response = await _repository.getVendorAccounts(vendorId);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Retrieved ${response.data!.length} accounts');
        return (success: true, message: response.message, accounts: response.data);
      } else {
        return (success: false, message: response.message, accounts: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to get accounts: $e', accounts: null);
    }
  }

  /// Get vendor banking details
  Future<({bool success, String? message, VendorBankingDetailsResponse? details})>
      getVendorBankingDetails(int vendorId) async {
    print('🏦 [VendorApiService] Getting banking details for vendor: $vendorId');

    try {
      final response = await _repository.getVendorBankingDetails(vendorId);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Banking details retrieved successfully');
        return (success: true, message: response.message, details: response.data);
      } else {
        return (success: false, message: response.message, details: null);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to get banking details: $e', details: null);
    }
  }

  /// Update vendor bank account
  Future<({bool success, String? message})> updateVendorAccount(
      int accountId, VendorBankAccount account) async {
    print('📝 [VendorApiService] Updating bank account: $accountId');

    try {
      final request = UpdateVendorAccountRequest(id: accountId, account: account);
      final response = await _repository.updateVendorAccount(request);

      if (response.success && response.data != null) {
        print('✅ [VendorApiService] Bank account updated successfully');
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to update account: $e');
    }
  }

  /// Delete vendor bank account
  Future<({bool success, String? message})> deleteVendorAccount(int accountId) async {
    print('🗑️ [VendorApiService] Deleting bank account: $accountId');

    try {
      final response = await _repository.deleteVendorAccount(accountId);

      if (response.success) {
        print('✅ [VendorApiService] Bank account deleted successfully');
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to delete account: $e');
    }
  }

  /// Toggle account status
  Future<({bool success, String? message})> toggleAccountStatus(int accountId, bool isActive) async {
    print('🔄 [VendorApiService] Toggling account status: $accountId');

    try {
      final request = ToggleAccountStatusRequest(id: accountId, isActive: isActive);
      final response = await _repository.toggleAccountStatus(request);

      if (response.success) {
        print('✅ [VendorApiService] Account status toggled successfully');
        notifyListeners();
        return (success: true, message: response.message);
      } else {
        return (success: false, message: response.message);
      }
    } catch (e) {
      print('🚨 [VendorApiService] Error: $e');
      return (success: false, message: 'Failed to toggle status: $e');
    }
  }

  /// Search vendors locally
  List<VendorApiModel> searchVendors(String query) {
    if (query.isEmpty) return _vendors;
    
    final lowerQuery = query.toLowerCase();
    return _vendors.where((vendor) {
      return vendor.name.toLowerCase().contains(lowerQuery) ||
          vendor.vendorCode.toLowerCase().contains(lowerQuery) ||
          vendor.email.toLowerCase().contains(lowerQuery) ||
          vendor.contactPerson.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Clear current vendor
  void clearCurrentVendor() {
    _currentVendor = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
