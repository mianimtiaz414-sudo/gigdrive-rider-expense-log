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
      return const Stream<User?>.empty();
    }
    return _auth.authStateChanges();
  }

  bool _hasProvider(String providerId) {
    final User? user = currentUser;
    if (user == null) {
      return false;
    }
    return user.providerData.any((UserInfo i) => i.providerId == providerId);
  }

  bool get usesPasswordProvider => _hasProvider('password');

  bool get usesGoogleProvider => _hasProvider('google.com');

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

  Future<void> sendPasswordReset(String email) async {
    _ensureAvailable();
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await sendPasswordReset(email);
  }

  Future<void> reauthWithPassword(String password) async {
    _ensureAvailable();
    final User? user = currentUser;
    final String? email = user?.email;
    if (user == null || email == null) {
      throw StateError('No signed-in account to verify.');
    }
    final AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<bool> verifyCurrentPassword(String password) async {
    try {
      await reauthWithPassword(password);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reauthWithGoogle() async {
    _ensureAvailable();
    final User? user = currentUser;
    if (user == null) {
      throw StateError('No signed-in account to verify.');
    }
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return false;
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
    return true;
  }

  Future<bool> reauthenticateGoogle() async {
    return await reauthWithGoogle();
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
