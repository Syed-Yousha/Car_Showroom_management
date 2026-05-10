import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores the active user's username + a salted SHA-256 hash of their
/// password locally on the machine, so subsequent restarts can re-prompt
/// for the password and verify it offline (no Firebase round-trip).
///
/// Flow:
///   • First boot: no stored creds → user signs in with Firebase, on
///     success we call [remember] to persist {username, salt, hash}.
///   • Every subsequent restart: [hasStoredCredentials] is true → the
///     login screen runs in "local lock" mode, calling [verify] on submit.
///     Firebase isn't contacted at all.
///   • Password change / sign-out: caller invokes [forget] so the next
///     boot falls back to Firebase login.
class LocalAuthService {
  static const _kUsername = 'local_auth_username';
  static const _kSalt = 'local_auth_salt';
  static const _kHash = 'local_auth_hash';

  Future<bool> hasStoredCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kHash) && prefs.containsKey(_kUsername);
  }

  Future<String?> storedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUsername);
  }

  Future<void> remember({
    required String username,
    required String password,
  }) async {
    final salt = _randomSalt();
    final hash = _hash(password, salt);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsername, username);
    await prefs.setString(_kSalt, salt);
    await prefs.setString(_kHash, hash);
  }

  Future<bool> verify({
    required String username,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final storedUser = prefs.getString(_kUsername);
    final storedSalt = prefs.getString(_kSalt);
    final storedHash = prefs.getString(_kHash);
    if (storedUser == null || storedSalt == null || storedHash == null) {
      return false;
    }
    if (storedUser.toLowerCase() != username.toLowerCase()) return false;
    return _hash(password, storedSalt) == storedHash;
  }

  Future<void> forget() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsername);
    await prefs.remove(_kSalt);
    await prefs.remove(_kHash);
  }

  String _hash(String password, String salt) {
    final bytes = utf8.encode('$salt|$password');
    return sha256.convert(bytes).toString();
  }

  String _randomSalt() {
    final ts = DateTime.now().microsecondsSinceEpoch;
    final r = ts.toRadixString(36);
    return sha256.convert(utf8.encode('inam_motors|$ts|$r')).toString();
  }
}
