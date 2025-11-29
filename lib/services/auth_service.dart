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

  // Add this method to your AuthService class
  Future<User?> signUpAndGetUser({required String email, required String password}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      return null;
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

  // RESET PASSWORD (Added in Feature 1)
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }

  // --- NEW METHOD ADDED HERE ---
  // CHANGE PASSWORD (Added in Feature 2)
  Future<String?> changePassword({required String currentPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null) return 'No user logged in.';

    // Create credentials with the OLD password to re-authenticate
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      // 1. Re-authenticate the user (This proves they know their current password)
      await user.reauthenticateWithCredential(cred);

      // 2. Update the password
      await user.updatePassword(newPassword);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unknown error occurred.';
    }
  }
}