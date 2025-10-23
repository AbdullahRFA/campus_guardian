import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Formats the timestamp into a readable date string
    final formattedDate = DateFormat.yMMMMd().format(post.createdAt.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: ListView(
        children: [
          // Show thumbnail if a URL is provided
          if (post.thumbnailUrl.isNotEmpty)
            Image.network(
              post.thumbnailUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              // Show a placeholder if the image fails to load
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                );
              },
            ),
          // Post content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'By ${post.speakerName} • $formattedDate',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const Divider(height: 32),
                // Use MarkdownBody to render the description, allowing for rich text
                MarkdownBody(
                  data: post.description,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    p: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}