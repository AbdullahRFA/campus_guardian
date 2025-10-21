import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SIGN UP with email & password
  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, return null
      return null;
    } on FirebaseAuthException catch (e) {
      // If there's an error, return the error message
      return e.message;
    }
  }

  // SIGN IN with email & password
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // If successful, return null
      return null;
    } on FirebaseAuthException catch (e) {
      // If there's an error, return the error message
      return e.message;
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}