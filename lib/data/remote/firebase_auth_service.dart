import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isAvailable => Firebase.apps.isNotEmpty;

  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => isAvailable ? _auth.currentUser : null;

  String? get uid => currentUser?.uid;

  Stream<User?> get authStateChanges {
    if (!isAvailable) {
      return Stream<User?>.empty();
    }
    return _auth.authStateChanges();
  }

  void _ensureAvailable() {
    if (!isAvailable) {
      throw StateError(
        'Cloud services are not configured. Add google-services.json to enable sign-in.',
      );
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    _ensureAvailable();
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    _ensureAvailable();
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    _ensureAvailable();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!isAvailable) {
      return;
    }
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
