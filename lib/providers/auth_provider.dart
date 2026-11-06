import 'dart:async';

import 'package:flutter/foundation.dart';
// "show" imports only these two names. firebase_auth also has a class
// called AuthProvider, which would clash with ours.
import 'package:firebase_auth/firebase_auth.dart'
    show User, FirebaseAuthException;

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../utils/auth_errors.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<AppUser?>? _profileSub;

  User? _firebaseUser;
  AppUser? profile;
  bool verified = false;
  bool initializing = true; // true until Firebase tells us who is logged in
  bool isLoading = false;
  bool isSavingProfile = false;
  String? error;

  AuthProvider(this._service) {
    _authSub = _service.authChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    verified = user?.emailVerified ?? false;
    // Stop listening to the previous user's profile
    await _profileSub?.cancel();
    _profileSub = null;
    profile = null;
    if (user == null) {
      initializing = false;
      notifyListeners(); // ring the bell: screens rebuild
      return;
    }
    try {
      await _service.createMissingProfile(user);
    } catch (e) {
      debugPrint('Could not create a missing profile: $e');
    }
    // Someone else may have logged in while we were waiting
    if (_firebaseUser?.uid != user.uid) return;
    // Listen to the profile, so a new name or role shows up straight away
    _profileSub = _service
        .watchProfile(user.uid)
        .listen(
          (p) {
            profile = p;
            initializing = false;
            notifyListeners();
          },
          onError: (Object e) {
            debugPrint('Loading profile failed: $e');
            initializing = false;
            notifyListeners();
          },
        );
  }

  bool get isLoggedIn => _firebaseUser != null;
  bool get isStaff => profile?.isStaff ?? false;
  String get email => _firebaseUser?.email ?? '';
  String? get uid => _firebaseUser?.uid;

  // The name to show: the saved profile name, else the name typed at sign-up
  String get displayName {
    final saved = profile?.name.trim() ?? '';
    if (saved.isNotEmpty) return saved;
    return _firebaseUser?.displayName?.trim() ?? '';
  }

  // For places that always need something to show, like "Reported by ..."
  String get nameOrEmail => displayName.isEmpty ? email : displayName;

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<bool> register(String name, String email, String password) => _run(
    () => _service.register(name: name, email: email, password: password),
  );

  Future<bool> checkVerified() async {
    verified = await _service.refreshAndCheckVerified();
    notifyListeners();
    return verified;
  }

  Future<void> resendVerification() => _service.resendVerification();

  // Returns null if it worked, or an error message to show
  Future<String?> updateName(String name) async {
    isSavingProfile = true;
    notifyListeners();
    try {
      await _service.updateName(name);
      return null; // the live profile shows the new name by itself
    } catch (e) {
      debugPrint('Saving name failed: $e');
      return 'Could not save your name. Please try again.';
    } finally {
      isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<void> logout() => _service.logout();

  // Shared loading + error handling, so login and register don't repeat it
  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      error = friendlyAuthError(e);
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _profileSub?.cancel();
    super.dispose();
  }
}
