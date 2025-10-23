import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import the go_router package
import '../models/mentor.dart';

class MentorCard extends StatelessWidget {
  final Mentor mentor;

  const MentorCard({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // MODIFIED: Navigate to the detail screen using the mentor's ID
          context.go('/app/profile/${mentor.id}');        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(mentor.profileImageUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentor.name,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                            mentor.title,
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: mentor.expertise.map((skill) => Chip(
                  label: Text(skill),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  labelStyle: TextStyle(color: theme.colorScheme.primary),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}