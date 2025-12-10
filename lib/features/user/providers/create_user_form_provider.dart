import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreateUserFormProvider extends ChangeNotifier {
  static const _storageKey = 'create_user_form_state';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final Map<String, dynamic> _formData = {
    'status': 'Active',
  };

  bool _isLoaded = false;

  String? getField(String key) => _formData[key] as String?;
  String get status => (_formData['status'] as String?) ?? 'Active';
  String? get designationId => _formData['designationId'] as String?;
  String? get departmentId => _formData['departmentId'] as String?;
  String? get roleId => _formData['roleId'] as String?;

  Future<void> loadFormState() async {
    if (_isLoaded) return;
    final storedValue = await _secureStorage.read(key: _storageKey);
    if (storedValue != null && storedValue.isNotEmpty) {
      try {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(jsonDecode(storedValue) as Map);
        _formData
          ..clear()
          ..addAll(data);
      } catch (_) {
        // If parsing fails, fall back to defaults
        _formData
          ..clear()
          ..addAll({'status': 'Active'});
      }
    }
    _formData['status'] ??= 'Active';
    _isLoaded = true;
    notifyListeners();
  }

  void updateField(String key, String? value) {
    if (value == null || value.isEmpty) {
      if (_formData.containsKey(key)) {
        _formData.remove(key);
      }
    } else {
      _formData[key] = value;
    }
    _persistFormState();
  }

  void updateStatus(String value) {
    _formData['status'] = value;
    _persistFormState();
  }

  void updateDesignation(String? value) {
    _updateOptionalField('designationId', value);
  }

  void updateDepartment(String? value) {
    _updateOptionalField('departmentId', value);
  }

  void updateRole(String? value) {
    _updateOptionalField('roleId', value);
  }

  void _updateOptionalField(String key, String? value) {
    if (value == null || value.isEmpty) {
      _formData.remove(key);
    } else {
      _formData[key] = value;
    }
    _persistFormState();
  }

  Future<void> clearFormState() async {
    _formData
      ..clear()
      ..addAll({'status': 'Active'});
    await _secureStorage.delete(key: _storageKey);
    notifyListeners();
  }

  Future<void> _persistFormState() async {
    await _secureStorage.write(
      key: _storageKey,
      value: jsonEncode(_formData),
    );
    notifyListeners();
  }
}
