import 'package:campus_guardian/services/database_service.dart'; // FIXED: Correct import path
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/skill_request.dart';

class RequestCard extends StatelessWidget {
  final SkillRequest request;
  const RequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = request.requesterId == currentUserId;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.title,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/app/skill-exchange/${request.id}/edit', extra: request);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Request'),
                            content: const Text('Are you sure you want to delete this skill request?'),
                            actions: [
                              TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                              TextButton(
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  // This will now work correctly
                                  DatabaseService().deleteSkillRequest(request.id);
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Posted by: ${request.requesterName}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: request.tags.map((tag) => Chip(label: Text(tag))).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${request.creditsOffered} Wisdom Credits', style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.amber[100],
                  avatar: Icon(Icons.star, color: Colors.amber[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}