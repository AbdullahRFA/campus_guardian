import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
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

    // --- DEBUGGING LOGIC ---
    // This will print to your console so you can see why it matches or fails
    if (currentUserId != null) {
      debugPrint("Post: ${post.title} | SpeakerID: ${post.speakerId} | MyID: $currentUserId");
    }

    // STRICT CHECK: Only show if I am the owner
    final bool isOwner = currentUserId != null && post.speakerId == currentUserId;

    // TESTING MODE: Show button on ALL posts (Uncomment the line below to force show)
    // final bool isOwner = true;
    // -----------------------

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
              context.push('/app/posts/${post.id}', extra: post);
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
                      // Header Row with Title and Optional Menu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Only show this widget if isOwner is true
                          if (isOwner)
                            SizedBox(
                              height: 30, // Increased touch target slightly
                              width: 30,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.more_vert, size: 24),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    context.push('/app/posts/${post.id}/edit', extra: post);
                                  } else if (value == 'delete') {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Post'),
                                        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
                                        actions: [
                                          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop()),
                                          TextButton(
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            onPressed: () {
                                              DatabaseService().deletePost(post.id);
                                              Navigator.of(ctx).pop();
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ),
                        ],
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
          // --- ACTION BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. LIKE BUTTON
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
                // 2. COMMENT BUTTON
                TextButton.icon(
                  icon: Icon(Icons.comment_outlined, size: 20, color: Colors.grey[700]),
                  label: Text(
                    'Comment',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onPressed: () {
                    context.push('/app/posts/${post.id}', extra: post);
                  },
                ),
                // 3. SHARE BUTTON
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