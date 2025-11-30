// features/chat/screens/chat_inbox_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Add intl package for date formatting

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  // Helper to format the timestamp to something like "10:30 AM" or "Yesterday"
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(date); // 10:30 AM
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(date); // Oct 24
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Please log in to see your messages.',
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Use theme background
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0, // Clean flat look
        centerTitle: false, // Modern left-aligned title
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('user_chats')
            .orderBy('lastActivity', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading chats', style: TextStyle(color: theme.colorScheme.error)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatDocs.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 80), // Modern divider
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final String chatId = chatData['chatId'];
              final String otherUserId = chatData['otherUserId'];
              final String otherUserName = chatData['otherUserName'] ?? 'Unknown User';
              final Timestamp? lastActivity = chatData['lastActivity'];
              // If you saved the 'lastMessage' text in your database, fetch it here.
              // For now, we will use a placeholder if it doesn't exist.
              final String lastMessage = chatData['lastMessage'] ?? 'Tap to open conversation';
              final String? profilePicUrl = chatData['otherUserProfilePic']; // Assuming you might have this

              return InkWell(
                onTap: () {
                  context.push(
                    '/chat/$chatId',
                    extra: {
                      'receiverId': otherUserId,
                      'receiverName': otherUserName,
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Avatar
                      Hero(
                        tag: 'avatar_$otherUserId',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: profilePicUrl != null && profilePicUrl.isNotEmpty
                              ? NetworkImage(profilePicUrl)
                              : null,
                          child: profilePicUrl == null || profilePicUrl.isEmpty
                              ? Text(
                            otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    otherUserName,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (lastActivity != null)
                                  Text(
                                    _formatTimestamp(lastActivity),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Messages Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Start a conversation by proposing a skill exchange or booking a mentorship session.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}