import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../services/database_service.dart';
import '../models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  String? _currentUserDisplayName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  Future<void> _loadCurrentUserData() async {
    if (_currentUserId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUserId).get();
      if (mounted) {
        setState(() {
          _currentUserDisplayName = userDoc.data()?['fullName'];
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty || _currentUserId == null) return;
    FocusScope.of(context).unfocus();
    await _databaseService.addComment(
      postId: widget.post.id,
      text: _commentController.text.trim(),
      commenterId: _currentUserId!,
      commenterName: _currentUserDisplayName ?? 'Anonymous',
    );
    _commentController.clear();
  }

  void _showReplyDialog(String commentId, String commentAuthorName) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reply to $commentAuthorName'),
          content: TextField(
            controller: replyController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Write your reply...'),
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('POST REPLY'),
              onPressed: () async {
                if (replyController.text.trim().isEmpty || _currentUserId == null) return;

                // FIXED: Added a try-catch block for robust error handling
                try {
                  await _databaseService.addReplyToComment(
                    postId: widget.post.id,
                    commentId: commentId,
                    text: replyController.text.trim(),
                    replierId: _currentUserId!,
                    replierName: _currentUserDisplayName ?? 'Anonymous',
                  );
                  if (mounted) Navigator.of(context).pop();
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Close the dialog first
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to post reply: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat.yMMMMd().format(widget.post.createdAt.toDate());
    // FIXED: The check is now for the specific post author, not any mentor.
    final bool isUserTheAuthor = _currentUserId != null && _currentUserId == widget.post.speakerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Post',
            onPressed: () {
              Share.share('Check out this post on CampusGuardian:\n"${widget.post.title}" by ${widget.post.speakerName}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (widget.post.thumbnailUrl.isNotEmpty)
                  Image.network(
                    widget.post.thumbnailUrl,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 220,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.post.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('By ${widget.post.speakerName} • $formattedDate', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
                      const Divider(height: 32),
                      MarkdownBody(data: widget.post.description, styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(p: theme.textTheme.bodyLarge?.copyWith(height: 1.5))),
                      const Divider(height: 32),
                      Text('Comments', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Padding(padding: EdgeInsets.all(24.0), child: Text('Be the first to comment!')),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final comment = snapshot.data!.docs[index];
                        final commentData = comment.data() as Map<String, dynamic>;
                        final replies = (commentData['replies'] as List<dynamic>? ?? []);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(commentData['commenterName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(commentData['text']),
                              ),
                              if (isUserTheAuthor)
                                Padding(
                                  padding: const EdgeInsets.only(left: 72.0),
                                  child: TextButton(
                                    child: const Text('Reply'),
                                    onPressed: () => _showReplyDialog(comment.id, commentData['commenterName']),
                                  ),
                                ),
                              ...replies.map((reply) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 56.0),
                                  child: ListTile(
                                    leading: const CircleAvatar(radius: 18, child: Icon(Icons.reply)),
                                    title: Text(reply['replierName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(reply['text']),
                                  ),
                                );
                              }).toList(),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _postComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}