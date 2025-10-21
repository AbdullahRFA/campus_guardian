import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the authentication state changes from Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show a loading indicator while checking the auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // This callback runs after the widget tree is built.
        // It safely navigates based on the auth state.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (snapshot.hasData) {
            // If user is logged in (snapshot has data), go to the main app.
            context.go('/app/dashboard');
          }
        });

        // If user is not logged in (or we are about to navigate away),
        // show the LoginScreen. This is the default state.
        return const LoginScreen();
      },
    );
  }
}