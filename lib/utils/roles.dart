// ALU gives students @alustudent.com addresses and staff @alueducation.com
// addresses, so the role is decided by the email when an account is made.
// An admin can still change a role by hand in the Firestore console.
const staffEmailDomain = 'alueducation.com';

String roleForEmail(String email) {
  final cleaned = email.trim().toLowerCase();
  return cleaned.endsWith('@$staffEmailDomain') ? 'staff' : 'student';
}
