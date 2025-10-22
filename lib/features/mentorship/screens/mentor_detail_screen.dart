import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/app_button.dart';
import '../models/mentor.dart';

class MentorDetailScreen extends StatelessWidget {
  final Mentor mentor;

  const MentorDetailScreen({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(mentor.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header Section ---
            Container(
              padding: const EdgeInsets.all(24.0),
              width: double.infinity,
              color: theme.primaryColor.withOpacity(0.05),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: mentor.profileImageUrl.isNotEmpty ? NetworkImage(mentor.profileImageUrl) : null,
                    child: mentor.profileImageUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mentor.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // FIXED: Changed from mentor.company to just mentor.title
                  Text(
                    mentor.title,
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // --- About Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // This is the new, dynamic text
                  Text(
                    mentor.mentorBio.isNotEmpty ? mentor.mentorBio : 'No bio provided.',
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const Divider(height: 32),

                  // --- Expertise Section ---
                  Text(
                    'Expertise',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: mentor.expertise.map((skill) => Chip(
                      label: Text(skill, style: const TextStyle(fontWeight: FontWeight.w500)),
                      backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Booking Button ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AppButton(
          text: 'Book a Session',
          onPressed: () {
            context.go('/app/mentors/${mentor.id}/book');
          },
        ),
      ),
    );
  }
}