import 'package:campus_guardian/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/exchange_post.dart';

class ExchangeCard extends StatelessWidget {
  final ExchangePost post;
  const ExchangeCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isOwner = post.offererId == currentUserId;

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Row for Offerer Info and Edit/Delete Menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Posted by: ${post.offererName}', style: theme.textTheme.bodySmall),
                if (isOwner)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/app/skill-exchange/${post.id}/edit', extra: post);
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Post'),
                            content: const Text('Are you sure you want to delete this exchange post?'),
                            actions: [
                              TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                              TextButton(
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                onPressed: () {
                                  DatabaseService().deleteExchangePost(post.id);
                                  Navigator.of(ctx).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
              ],
            ),
            const Divider(),
            // Offer Section
            _buildSection(context, 'OFFERS', post.offerTitle, post.offerTags),
            // "Swap" Icon Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.swap_vert, color: Colors.grey, size: 28),
            ),
            // Request Section
            _buildSection(context, 'WANTS', post.requestTitle, post.requestTags),
            const SizedBox(height: 16),
            // Action Button
            ElevatedButton(
              onPressed: () {}, // Will implement "Propose Exchange" later
              child: const Text('Propose Exchange'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String header, String title, List<String> tags) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6.0,
          runSpacing: 4.0,
          children: tags.map((tag) => Chip(label: Text(tag), padding: EdgeInsets.zero)).toList(),
        ),
      ],
    );
  }
}