import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../utils/constants.dart';
import '../utils/roles.dart';

// All the Firebase calls for login and accounts live here,
// so the provider and screens never talk to Firebase directly.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _profileDoc(String uid) =>
      _db.collection(usersCollection).doc(uid);

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

    // The role comes from the email: @alueducation.com = staff, else student
    final cleanEmail = email.trim().toLowerCase();
    final profile = AppUser(
      uid: user.uid,
      name: name.trim(),
      email: cleanEmail,
      role: roleForEmail(cleanEmail),
    );
    await _profileDoc(user.uid).set({
      ...profile.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Only someone who can open this ALU inbox can finish signing up
    await user.sendEmailVerification();
  }

  // The user's profile, live: sends a new value whenever it changes in
  // Firestore (a new name, or an admin changing the role). null = no profile.
  Stream<AppUser?> watchProfile(String uid) => _profileDoc(uid).snapshots().map(
    (doc) => doc.exists ? AppUser.fromMap(uid, doc.data()!) : null,
  );

  // Accounts made before profiles were saved have no profile document.
  // This creates one from the login details, so the name and role work.
  // A transaction makes "check, then create" one step, so it can never
  // overwrite a profile that register() saved at the same moment.
  Future<void> createMissingProfile(User user) {
    final ref = _profileDoc(user.uid);
    final email = (user.email ?? '').toLowerCase();
    return _db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      if (doc.exists) return;
      tx.set(ref, {
        'name': user.displayName?.trim() ?? '',
        'email': email,
        'role': roleForEmail(email),
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Saves a new name in Firestore and in Firebase Auth
  Future<void> updateName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _profileDoc(user.uid).update({'name': name.trim()});
    await user.updateDisplayName(name.trim());
  }

  // Firebase caches the user, so reload to see if they clicked the email link
  Future<bool> refreshAndCheckVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    // Get a fresh login token too, so the Firestore rules see the change
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> resendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> logout() => _auth.signOut();
}
