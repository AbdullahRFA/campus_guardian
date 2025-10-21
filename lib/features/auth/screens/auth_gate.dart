import 'package:flutter/material.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we always show the login screen.
    // Tomorrow, we'll add logic here to check if the user
    // is actually logged in with Firebase.
    return const LoginScreen();
  }
}