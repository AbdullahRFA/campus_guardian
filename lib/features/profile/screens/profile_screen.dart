import 'package:campus_guardian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
              context.go('/login');
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Listen to real-time changes in the user's document
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          // Extract data from the document
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String fullName = userData['fullName'] ?? 'No Name';
          String email = userData['email'] ?? 'No Email';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Placeholder for profile picture
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 20),
                Text(fullName, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(email, style: Theme.of(context).textTheme.bodyLarge),
                // We will add an "Edit Profile" button here tomorrow
              ],
            ),
          );
        },
      ),
    );
  }
}