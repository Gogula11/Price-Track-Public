import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:TrueTrack/models/app_user.dart';
import 'package:TrueTrack/services/service_registry.dart';

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth? _auth;
  AppUser? _user;
  bool _initialized = false;

  AuthProvider({
    fb.FirebaseAuth? auth,
  }) : _auth = auth;

  AppUser? get user {
    if (_registry?.mockMode == true) {
      return const AppUser(
        email: 'demo@truetrack.app',
        joinDate: null,
      );
    }
    return _user;
  }

  bool get isAuthenticated {
    if (_registry?.mockMode == true) return true;
    return _user != null;
  }

  bool get initialized => _initialized;

  ServiceRegistry? _registry;

  void attachRegistry(ServiceRegistry registry) {
    _registry = registry;
  }

  void initialize() {
    if (_auth != null) {
      _auth.authStateChanges().listen(_onAuthStateChanged);
    } else {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(fb.User? firebaseUser) async {
    if (firebaseUser != null) {
      _user = AppUser(
        email: firebaseUser.email ?? '',
        photoUrl: firebaseUser.photoURL,
        joinDate: firebaseUser.metadata.creationTime,
      );
    } else {
      _user = null;
    }
    _initialized = true;
    notifyListeners();

    if (firebaseUser != null && _registry?.mockMode == false) {
      await _registry?.notification.saveFcmToken(firebaseUser);
      _registry?.notification.listenTokenRefresh(firebaseUser);
    }
  }

  Future<void> signOut() async {
    if (_user != null && _registry?.mockMode == false) {
      final firebaseUser = _auth?.currentUser;
      if (firebaseUser != null) {
        await _registry?.notification.removeFcmToken(firebaseUser);
      }
    }
    if (_auth != null) {
      await _auth.signOut();
    }
    _user = null;
    notifyListeners();
  }
}
