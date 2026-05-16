import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

/// Wraps FirebaseAuth and centralises username→email mapping.
///
/// This app uses **username + password** in the UI; usernames are mapped
/// internally to `<username>@inammotors.local` so they fit Firebase's
/// Email/Password provider. Users must be created in the Firebase Console
/// (Authentication → Users → Add user) using that email format.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String authDomain = 'inammotors.local';

  static String emailFromUsername(String username) {
    final u = username.trim();
    if (u.contains('@')) return u; // already an email
    return '$u@$authDomain';
  }

  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().map(
        (u) => u == null ? null : AppUser.fromFirebase(u),
      );

  AppUser? get currentUser {
    final u = _auth.currentUser;
    return u == null ? null : AppUser.fromFirebase(u);
  }

  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    final email = emailFromUsername(username);
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final u = cred.user;
    if (u == null) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Sign-in returned no user.',
      );
    }
    return AppUser.fromFirebase(u);
  }

  Future<void> signOut() => _auth.signOut();

  /// Re-authenticates the current user with [password]. Returns true if the
  /// password matches; false on any auth error (wrong password, no user,
  /// network failure). Use this to gate destructive operations.
  Future<bool> verifyPassword(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return false;
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } on FirebaseAuthException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Re-authenticates with the current password, then updates to the new one.
  /// Throws FirebaseAuthException on any failure (caller maps to UI message).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user.',
      );
    }
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  /// Maps Firebase auth errors to friendly messages for the UI.
  static String describeError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid username format.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'Incorrect username or password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again in a minute.';
        case 'network-request-failed':
          return 'No internet connection.';
        case 'weak-password':
          return 'Password is too weak (minimum 6 characters).';
        case 'requires-recent-login':
          return 'Please sign in again before changing your password.';
        case 'no-current-user':
          return 'No signed-in user.';
      }
      return e.message ?? 'Authentication error (${e.code}).';
    }
    return 'Unexpected error: $e';
  }
}
