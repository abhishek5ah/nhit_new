import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Base class that automatically persists form data into secure storage so
/// partially completed forms survive refresh/navigation.
abstract class PersistentFormProvider extends ChangeNotifier {
  PersistentFormProvider({
    required this.storageKey,
    Map<String, dynamic>? defaults,
  })  : _defaults = Map<String, dynamic>.from(defaults ?? const {}),
        _formData = Map<String, dynamic>.from(defaults ?? const {});

  final String storageKey;
  final Map<String, dynamic> _defaults;
  Map<String, dynamic> _formData;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isLoaded = false;

  Map<String, dynamic> get data => _formData;

  T? getField<T>(String key) => _formData[key] as T?;

  Future<void> loadFormState() async {
    if (_isLoaded) return;
    final storedValue = await _secureStorage.read(key: storageKey);
    if (storedValue != null && storedValue.isNotEmpty) {
      try {
        final decoded = jsonDecode(storedValue);
        if (decoded is Map<String, dynamic>) {
          _formData = {
            ..._defaults,
            ...decoded,
          };
        }
      } catch (_) {
        _formData = Map<String, dynamic>.from(_defaults);
      }
    }
    _isLoaded = true;
    notifyListeners();
  }

  void updateField(String key, dynamic value) {
    if (value == null || (value is String && value.isEmpty)) {
      _formData.remove(key);
    } else {
      _formData[key] = value;
    }
    _persist();
  }

  void updateList(String key, List<dynamic> values) {
    _formData[key] = values;
    _persist();
  }

  Future<void> clearFormState() async {
    _formData = Map<String, dynamic>.from(_defaults);
    await _secureStorage.delete(key: storageKey);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _secureStorage.write(
      key: storageKey,
      value: jsonEncode(_formData),
    );
    notifyListeners();
  }
}
