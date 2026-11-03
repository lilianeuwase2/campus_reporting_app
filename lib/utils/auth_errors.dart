import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

// Turns Firebase's error codes into messages a user can understand
String friendlyAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'That email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'weak-password':
      return 'Password is too weak. Use at least 8 characters.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait and try again.';
    case 'network-request-failed':
      return 'No internet connection. Check your network.';
    default:
      return e.message ?? 'Something went wrong. Please try again.';
  }
}
