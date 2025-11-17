import 'package:flutter/foundation.dart';
import 'package:ppv_components/core/services/auth_service.dart';

class AuthNotifier extends ChangeNotifier {
  final AuthService _authService;
  
  AuthNotifier(this._authService) {
    // Listen to auth state changes and notify router
    _authService.addListener(_onAuthStateChanged);
  }
  
  void _onAuthStateChanged() {
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
