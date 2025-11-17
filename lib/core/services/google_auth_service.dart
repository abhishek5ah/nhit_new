// Google Auth Service - Stub implementation for testing
// TODO: Implement proper Google Sign-In integration once backend SSO is ready

class GoogleAuthService {
  // Sign in with Google
  static Future<({bool success, String? message})> signInWithGoogle() async {
    // Stub implementation for testing
    return (
      success: false, 
      message: 'Google sign-in is not yet implemented. Please use email/password login.'
    );
  }

  // Sign out from Google
  static Future<void> signOut() async {
    // Stub implementation
  }

  // Check if user is signed in to Google
  static Future<bool> isSignedIn() async {
    // Stub implementation
    return false;
  }

  // Disconnect from Google (revoke access)
  static Future<void> disconnect() async {
    // Stub implementation
  }
}
