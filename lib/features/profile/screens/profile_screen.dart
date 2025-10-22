import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:campus_guardian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  // Load the saved image path from SharedPreferences
  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _localImagePath = prefs.getString('profile_pic_path_$currentUserId');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () async {
              // After returning from edit, reload the local image path
              await context.push('/app/profile/edit');
              _loadLocalImage();
            },
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
          String firestoreImageUrl = userData['profilePicUrl'] ?? '';

          ImageProvider? backgroundImage;
          // Priority 1: Use the freshly loaded local path
          if (_localImagePath != null && _localImagePath!.isNotEmpty) {
            if (kIsWeb) {
              backgroundImage = NetworkImage(_localImagePath!); // For blob:http URL
            } else {
              backgroundImage = FileImage(File(_localImagePath!));
            }
          }
          // Priority 2: Use the path from Firestore (fallback)
          else if (firestoreImageUrl.isNotEmpty) {
            if (firestoreImageUrl.startsWith('http')) {
              backgroundImage = NetworkImage(firestoreImageUrl);
            } else if (!kIsWeb) {
              backgroundImage = FileImage(File(firestoreImageUrl));
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: backgroundImage,
                      child: backgroundImage == null ? const Icon(Icons.person, size: 50) : null,
                    ),
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
              _buildProfileInfoTile(Icons.facebook, 'Facebook', userData['facebookUrl']),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoTile(IconData icon, String title, String? subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle != null && subtitle.isNotEmpty ? subtitle : 'Not set'),
    );
  }
}