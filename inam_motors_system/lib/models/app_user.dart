import 'package:firebase_auth/firebase_auth.dart' as fb;

class AppUser {
  final String uid;
  final String email;
  final String? displayName;

  const AppUser({required this.uid, required this.email, this.displayName});

  factory AppUser.fromFirebase(fb.User u) =>
      AppUser(uid: u.uid, email: u.email ?? '', displayName: u.displayName);

  String get usernameFromEmail {
    final at = email.indexOf('@');
    return at == -1 ? email : email.substring(0, at);
  }
}
