import 'package:campus_guardian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () => context.push('/app/profile/edit'), // Navigate to Edit Screen
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              AuthService().signOut();
              context.go('/login');
            },
          )
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
                    const SizedBox(height: 16),
                    Text(userData['fullName'] ?? 'N/A', style: Theme.of(context).textTheme.headlineSmall),
                    Text(userData['email'] ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(userData['bio'] ?? 'No bio provided.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const Divider(height: 32),
              _buildProfileInfoTile(Icons.school, 'Department', userData['department']),
              _buildProfileInfoTile(Icons.group, 'Batch', userData['batch']),
              _buildProfileInfoTile(Icons.format_list_numbered, 'Class Roll', userData['classRoll']),
              _buildProfileInfoTile(Icons.phone, 'Phone', userData['phoneNumber']),
              _buildProfileInfoTile(Icons.link, 'LinkedIn', userData['linkedinUrl']),
              // Add more tiles for other fields as needed
            ],
          );
        },
      ),
    );
  }

  // Helper widget for a consistent look
  Widget _buildProfileInfoTile(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle ?? 'Not set'),
    );
  }
}