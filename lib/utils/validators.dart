import 'constants.dart';

// Each validator returns an error message, or null when the value is fine.
// That is the shape TextFormField's validator expects.

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter your full name';
  if (value.trim().length < 2) return 'Name is too short';
  return null;
}

String? validateAluEmail(String? value) {
  final email = value?.trim().toLowerCase() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email';
  }
  final domain = email.split('@').last;
  if (!aluEmailDomains.contains(domain)) {
    return 'Use your ALU email (${aluEmailDomains.join(' or ')})';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Enter a password';
  if (value.length < 8) return 'Password must be at least 8 characters';
  return null;
}
