import 'package:flutter/material.dart';
import 'package:campus_guardian/services/auth_service.dart';
import 'package:go_router/go_router.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          // Add a Logout button to the AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              // After signing out, redirect to the login screen
              context.go('/login');
            },
          )
        ],
      ),
      body: const Center(
        child: Text('User profile information will be shown here.'),
      ),
    );
  }
}