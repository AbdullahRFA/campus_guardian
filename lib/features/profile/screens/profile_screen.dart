import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:campus_guardian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:campus_guardian/features/mentorship/models/session.dart';
import 'package:campus_guardian/features/profile/widgets/session_history_card.dart';

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

  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _localImagePath = prefs.getString('profile_pic_path_$currentUserId');
      });
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
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
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          // --- FIX APPLIED HERE ---
          // 1. Get the data object first. It can be null.
          final documentData = userSnapshot.data!.data();

          // 2. Check if the data is null (document exists but is empty).
          if (documentData == null) {
            return const Center(
              child: Text('Profile is empty. Please edit your profile to add details.'),
            );
          }

          // 3. Now it's safe to cast the data.
          var userData = documentData as Map<String, dynamic>;
          // --- END OF FIX ---

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              _buildProfileHeader(context, userData),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Academic Details',
                icon: Icons.school,
                children: [
                  _buildProfileInfoTile(Icons.business, 'University', userData['university']),
                  _buildProfileInfoTile(Icons.bookmark, 'Department', userData['department']),
                  _buildProfileInfoTile(Icons.timeline, 'Session', userData['session']),
                  _buildProfileInfoTile(Icons.group, 'Batch', userData['batch']),
                  _buildProfileInfoTile(Icons.format_list_numbered, 'Class Roll', userData['classRoll']),
                  _buildProfileInfoTile(Icons.star, 'B.Sc CGPA', userData['bscCgpa']),
                  _buildProfileInfoTile(Icons.star_border, 'M.Sc CGPA', userData['mscCgpa']),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Mentorship',
                icon: Icons.people_outline,
                children: [
                  ListTile(
                    title: const Text("Manage Your Mentor Profile"),
                    subtitle: const Text("Set your availability and expertise"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/app/profile/edit-mentor'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    title: const Text("My Published Posts"),
                    subtitle: const Text("View posts you have created"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/app/my-posts'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Contact Information',
                icon: Icons.contact_page,
                children: [
                  _buildProfileInfoTile(Icons.email, 'Email', userData['email']),
                  _buildProfileInfoTile(Icons.phone, 'Phone', userData['phoneNumber']),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Social Links',
                icon: Icons.public,
                children: [
                  _buildSocialLinkTile(Icons.link, 'LinkedIn', userData['linkedinUrl']),
                  _buildSocialLinkTile(Icons.facebook, 'Facebook', userData['facebookUrl']),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                context,
                title: 'Session History & Feedback',
                icon: Icons.history,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sessions')
                        .where('participants', arrayContains: currentUserId)
                        .where('status', isEqualTo: 'completed')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, sessionSnapshot) {
                      if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                      }
                      if (sessionSnapshot.hasError) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Could not load session history.'),
                        );
                      }

                      if (!sessionSnapshot.hasData || sessionSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No completed sessions yet.')));
                      }

                      return Column(
                        children: sessionSnapshot.data!.docs.map((doc) {
                          final session = Session.fromFirestore(doc);
                          return SessionHistoryCard(session: session, profileOwnerId: currentUserId);
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    String firestoreImageUrl = userData['profilePicUrl'] ?? '';
    ImageProvider? backgroundImage;

    if (_localImagePath != null && _localImagePath!.isNotEmpty) {
      backgroundImage = kIsWeb ? NetworkImage(_localImagePath!) : FileImage(File(_localImagePath!)) as ImageProvider;
    } else if (firestoreImageUrl.isNotEmpty) {
      backgroundImage = firestoreImageUrl.startsWith('http') ? NetworkImage(firestoreImageUrl) : (kIsWeb ? null : FileImage(File(firestoreImageUrl)) as ImageProvider);
    }

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: backgroundImage,
              child: backgroundImage == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 16),
            Text(userData['fullName'] ?? 'N/A', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(userData['email'] ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Text(
              userData['bio'] != null && userData['bio'].isNotEmpty ? userData['bio'] : 'No bio provided.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile(IconData icon, String title, String? subtitle) {
    final bool hasData = subtitle != null && subtitle.isNotEmpty;
    return ListTile(
      leading: Icon(icon, size: 28, color: Colors.grey[500]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        hasData ? subtitle : 'Not set',
        style: TextStyle(fontSize: 16, color: hasData ? Colors.black87 : Colors.grey),
      ),
    );
  }

  Widget _buildSocialLinkTile(IconData icon, String title, String? url) {
    final bool hasUrl = url != null && url.isNotEmpty;
    return ListTile(
      leading: Icon(icon, size: 28, color: hasUrl ? Theme.of(context).colorScheme.primary : Colors.grey[500]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        hasUrl ? url : 'Not set',
        style: TextStyle(fontSize: 14, color: hasUrl ? Colors.blue : Colors.grey, decoration: hasUrl ? TextDecoration.underline : null),
        overflow: TextOverflow.ellipsis,
      ),
      onTap: hasUrl ? () => _launchURL(url) : null,
      trailing: hasUrl ? const Icon(Icons.open_in_new, size: 20) : null,
    );
  }
}