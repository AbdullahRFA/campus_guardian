import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart'; // Import the share package
import '../models/post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campus_guardian/services/database_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final bool isLiked = currentUserId != null && post.likes.contains(currentUserId);

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          // --- MODIFIED ACTION BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // This creates the spacing
              children: [
                // 1. LIKE BUTTON (Left)
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        if (currentUserId != null) {
                          DatabaseService().togglePostLike(post.id, currentUserId);
                        }
                      },
                      tooltip: isLiked ? 'Unlike' : 'Like',
                    ),
                    Text('${post.likes.length}'),
                  ],
                ),
                // 2. COMMENT BUTTON (Middle)
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined, size: 20, color: Colors.grey[700]),
                  label: Text(
                    'Comment',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onPressed: () {
                    context.go('/app/posts/${post.id}', extra: post);
                  },
                ),
                // 3. SHARE BUTTON (Right)
                IconButton(
                  icon: Icon(Icons.share_outlined, color: Colors.grey[700]),
                  tooltip: 'Share Post',
                  onPressed: () {
                    Share.share('Check out this post on CampusGuardian: "${post.title}" by ${post.speakerName}');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}