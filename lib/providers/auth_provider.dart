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
  StreamSubscription<User?>? _sub;

  User? _firebaseUser;
  AppUser? profile;
  bool verified = false;
  bool initializing = true; // true until Firebase tells us who is logged in
  bool isLoading = false;
  String? error;

  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    verified = user?.emailVerified ?? false;
    try {
      profile = user == null ? null : await _service.loadProfile(user.uid);
    } catch (_) {
      profile = null;
    }
    initializing = false;
    notifyListeners(); // ring the bell: screens rebuild
  }

  bool get isLoggedIn => _firebaseUser != null;
  bool get isStaff => profile?.isStaff ?? false;
  String get email => _firebaseUser?.email ?? '';
  String? get uid => _firebaseUser?.uid;

  Future<bool> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<bool> register(String name, String email, String password) => _run(
    () => _service.register(name: name, email: email, password: password),
  );

  Future<bool> checkVerified() async {
    verified = await _service.refreshAndCheckVerified();
    if (verified && uid != null) profile = await _service.loadProfile(uid!);
    notifyListeners();
    return verified;
  }

  Future<void> resendVerification() => _service.resendVerification();

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
    _sub?.cancel();
    super.dispose();
  }
}
