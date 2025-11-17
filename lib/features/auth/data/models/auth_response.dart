import 'package:ppv_components/features/auth/data/models/user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('🔍 [AuthResponse] Starting AuthResponse JSON parsing...');
    print('📋 [AuthResponse] JSON keys present: ${json.keys.toList()}');
    
    try {
      final accessToken = json['accessToken'] ?? '';
      final refreshToken = json['refreshToken'] ?? '';
      final userJson = json['user'] ?? {};
      
      print('🔑 [AuthResponse] Access Token present: ${accessToken.isNotEmpty}');
      print('🔄 [AuthResponse] Refresh Token present: ${refreshToken.isNotEmpty}');
      print('👤 [AuthResponse] User data present: ${userJson.isNotEmpty}');
      
      print('🔄 [AuthResponse] Parsing UserModel...');
      final user = UserModel.fromJson(userJson);
      print('✅ [AuthResponse] UserModel parsed successfully');
      
      final response = AuthResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
      );
      
      print('🎉 [AuthResponse] AuthResponse parsing completed successfully');
      return response;
      
    } catch (e, stackTrace) {
      print('🚨 [AuthResponse] ERROR during AuthResponse parsing:');
      print('   JSON that failed to parse: $json');
      print('   Error: $e');
      print('   Stack Trace: $stackTrace');
      print('================== AUTH RESPONSE ERROR END ==================');
      
      // Rethrow the error for upstream handling
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }
}
