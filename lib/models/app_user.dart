class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'staff'

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isStaff => role == 'staff';

  // Builds an AppUser from a Firestore users document
  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
    );
  }

  // Turns an AppUser into data we can save in Firestore
  Map<String, dynamic> toMap() => {'name': name, 'email': email, 'role': role};
}
