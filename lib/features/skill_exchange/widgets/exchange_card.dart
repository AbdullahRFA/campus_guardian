// widgets/exchange_card.dart

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Posted by: ${post.offererName}', style: theme.textTheme.bodySmall),
                // --- START OF MODIFIED SECTION ---
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
                            content: const Text('Are you sure you want to delete this exchange post? This action cannot be undone.'),
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
                      } else if (value == 'close') {
                        // This action is for an 'open' post
                        DatabaseService().updateExchangePostStatus(post.id, 'closed');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post hidden and moved to your history.'),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      } else if (value == 'reopen') {
                        // This action is for a 'closed' post
                        DatabaseService().updateExchangePostStatus(post.id, 'open');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Post has been re-listed to the public feed.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      // Conditionally show "Close" or "Re-list" based on post status
                      if (post.status == 'open')
                        const PopupMenuItem(value: 'close', child: Text('Mark as Closed'))
                      else
                        const PopupMenuItem(value: 'reopen', child: Text('Re-list as Open')),
                      const PopupMenuDivider(),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                // --- END OF MODIFIED SECTION ---
              ],
            ),
            const Divider(),
            _buildSection(context, 'OFFERS', post.offerTitle, post.offerTags),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.swap_vert, color: Colors.grey, size: 28),
            ),
            _buildSection(context, 'WANTS', post.requestTitle, post.requestTags),
            const SizedBox(height: 16),
            if (!isOwner && currentUserId != null)
              ElevatedButton(
                onPressed: () {
                  final String user1 = currentUserId;
                  final String user2 = post.offererId;
                  List<String> ids = [user1, user2];
                  ids.sort();
                  final String chatId = ids.join('_');
                  context.push(
                    '/chat/$chatId',
                    extra: {
                      'receiverId': post.offererId,
                      'receiverName': post.offererName,
                    },
                  );
                },
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
        if (tags.isNotEmpty)
          Wrap(
            spacing: 6.0,
            runSpacing: 4.0,
            children: tags.map((tag) => Chip(label: Text(tag), padding: EdgeInsets.zero)).toList(),
          ),
      ],
    );
  }
}