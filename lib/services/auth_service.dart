import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';

// All the Firebase calls for login and accounts live here,
// so the provider and screens never talk to Firebase directly.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fires whenever someone logs in or out
  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    await user.updateDisplayName(name.trim());

    // Everyone starts as a student; staff roles are set in Firestore by an admin
    final profile = AppUser(
      uid: user.uid,
      name: name.trim(),
      email: email.trim(),
      role: 'student',
    );
    await _db.collection(usersCollection).doc(user.uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Email verification is turned off for now; see AuthGate
  }

  Future<AppUser?> loadProfile(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  // Firebase caches the user, so reload to see if they clicked the email link
  Future<bool> refreshAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> logout() => _auth.signOut();
}
