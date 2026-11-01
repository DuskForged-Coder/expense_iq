import 'package:expense_iq/core/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  AuthService(this._preferences);

  final SharedPreferences _preferences;
  final Uuid _uuid = const Uuid();

  static const String _localUserKey = 'local_user_email';

  AppUser? currentUser() {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.email != null) {
        return AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? firebaseUser.email!.split('@').first,
          photoUrl: firebaseUser.photoURL,
        );
      }
    } on Object {
      return _localUser();
    }
    return _localUser();
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    _validateEmailPassword(email, password);
    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null && user.email != null) {
        return AppUser(
          id: user.uid,
          email: user.email!,
          name: user.displayName ?? user.email!.split('@').first,
          photoUrl: user.photoURL,
        );
      }
    } on Object {
      await _preferences.setString(_localUserKey, email);
      return AppUser(id: 'local-${_uuid.v4()}', email: email, name: email.split('@').first);
    }
    throw StateError('Unable to sign in.');
  }

  Future<AppUser> signUpWithEmail(String email, String password) async {
    _validateEmailPassword(email, password);
    try {
      final credential = await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user != null && user.email != null) {
        return AppUser(
          id: user.uid,
          email: user.email!,
          name: user.email!.split('@').first,
        );
      }
    } on Object {
      await _preferences.setString(_localUserKey, email);
      return AppUser(id: 'local-${_uuid.v4()}', email: email, name: email.split('@').first);
    }
    throw StateError('Unable to create account.');
  }

  Future<AppUser> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw StateError('Google sign-in was cancelled.');
    }
    final auth = await googleUser.authentication;
    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final result =
        await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
    final user = result.user;
    if (user == null || user.email == null) {
      throw StateError('Google sign-in did not return an email address.');
    }
    return AppUser(
      id: user.uid,
      email: user.email!,
      name: user.displayName ?? user.email!.split('@').first,
      photoUrl: user.photoURL,
    );
  }

  Future<void> sendPasswordReset(String email) async {
    if (!email.contains('@')) {
      throw ArgumentError('Enter a valid email address.');
    }
    await firebase_auth.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await firebase_auth.FirebaseAuth.instance.signOut();
    await _preferences.remove(_localUserKey);
  }

  void _validateEmailPassword(String email, String password) {
    if (!email.contains('@')) {
      throw ArgumentError('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters.');
    }
  }

  AppUser? _localUser() {
    final email = _preferences.getString(_localUserKey);
    if (email == null) {
      return null;
    }
    return AppUser(id: 'local-$email', email: email, name: email.split('@').first);
  }
}
