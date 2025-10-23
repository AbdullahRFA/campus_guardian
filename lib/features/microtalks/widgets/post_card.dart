// lib/features/microtalks/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_guardian/services/database_service.dart'; // Import DatabaseService

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid; // Use nullable uid
    final bool isLiked = currentUserId != null && post.likes.contains(currentUserId);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column( // Wrap InkWell content in a Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Make only the top part (image + text) tappable for navigation
          InkWell(
            onTap: () {
              context.go('/app/posts/${post.id}', extra: post);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.thumbnailUrl.isNotEmpty)
                  Image.network(
                    post.thumbnailUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${post.speakerName}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- NEW: Action Bar ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        // Only allow logged-in users to like
                        if (currentUserId != null) {
                          DatabaseService().togglePostLike(post.id, currentUserId);
                        } else {
                          // Optional: Show a message asking the user to log in
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please log in to like posts.')),
                          );
                        }
                      },
                      tooltip: isLiked ? 'Unlike' : 'Like',
                    ),
                    Text('${post.likes.length}'), // Display like count
                  ],
                ),
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined, size: 20, color: Colors.grey[700]),
                  label: Text(
                    'Comment', // We can add comment count later
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onPressed: () {
                    // Navigate to the detail screen (where comments will be)
                    context.go('/app/posts/${post.id}', extra: post);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Add a little spacing at the bottom
        ],
      ),
    );
  }
}