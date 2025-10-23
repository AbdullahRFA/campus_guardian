import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:campus_guardian/features/mentorship/models/session.dart';
import 'package:campus_guardian/features/profile/widgets/session_history_card.dart';
import 'package:campus_guardian/widgets/app_button.dart';

class PublicProfileScreen extends StatelessWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  // Helper function to launch URLs safely
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
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
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User profile not found.'));
          }

          var userData = userSnapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            children: [
              _buildProfileHeader(context, userData),
              const SizedBox(height: 16),
              // Conditionally show the Mentorship Profile card if the user is a mentor
              if (userData['isMentorAvailable'] == true) ...[
                _buildInfoCard(
                  context,
                  title: 'Mentorship Profile',
                  icon: Icons.school,
                  children: [
                    _buildProfileInfoTile(Icons.work, 'Title', userData['mentorTitle']),
                    _buildProfileInfoTile(Icons.info_outline, 'Bio', userData['mentorBio']),
                    // Displaying expertise as chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: (userData['mentorExpertise'] as List<dynamic>? ?? [])
                            .map((skill) => Chip(label: Text(skill as String)))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              _buildInfoCard(
                context,
                title: 'Session History & Feedback',
                icon: Icons.history,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('sessions')
                        .where('participants', arrayContains: userId)
                        .where('status', isEqualTo: 'completed')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, sessionSnapshot) {
                      if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                      }
                      if (!sessionSnapshot.hasData || sessionSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No completed sessions yet.')));
                      }
                      return Column(
                        children: sessionSnapshot.data!.docs.map((doc) {
                          final session = Session.fromFirestore(doc);
                          // FIXED: Pass the userId of the public profile to the card
                          return SessionHistoryCard(session: session, profileOwnerId: userId);
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
      // Conditionally shows the "Book a Session" button at the bottom
      bottomNavigationBar: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          bool isMentor = userData['isMentorAvailable'] ?? false;

          // Only show the button if the viewed user is an available mentor
          if (isMentor) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppButton(
                text: 'Book a Session',
                onPressed: () {
                  // Navigate to the booking screen for this user
                  context.go('/app/profile/$userId/book');
                },
              ),
            );
          } else {
            return const SizedBox.shrink(); // Show nothing if not a mentor
          }
        },
      ),
    );
  }

  // Helper Widgets
  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic> userData) {
    String profilePicUrl = userData['profilePicUrl'] ?? '';
    ImageProvider? backgroundImage;
    if (profilePicUrl.isNotEmpty) {
      backgroundImage = profilePicUrl.startsWith('http') ? NetworkImage(profilePicUrl) : (kIsWeb ? null : FileImage(File(profilePicUrl)) as ImageProvider);
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
            Text(userData['bio'] ?? 'No bio provided.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic)),
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
}