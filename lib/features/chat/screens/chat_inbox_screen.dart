import 'package:campus_guardian/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  /// Helper to format the timestamp
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your messages.')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
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
            debugPrint("Chat Error: ${snapshot.error}"); // DEBUG PRINT
            return Center(
                child: Text('Error loading chats', style: TextStyle(color: theme.colorScheme.error)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chatDocs.length,
            separatorBuilder: (ctx, i) => const Divider(height: 1, indent: 80),
            itemBuilder: (context, index) {
              final data = chatDocs[index].data() as Map<String, dynamic>;

              // --- DEBUGGING SECTION START ---
              // Look at your "Run" console for this output!
              debugPrint("Chat Data for ${data['otherUserName']}: $data");
              // --- DEBUGGING SECTION END ---

              // Extract Data safely
              final String chatId = data['chatId'] ?? '';
              final String otherUserId = data['otherUserId'] ?? '';
              final String otherUserName = data['otherUserName'] ?? 'User';
              final String lastMessage = data['lastMessage'] ?? 'Tap to view';
              final Timestamp? lastActivity = data['lastActivity'];
              final String? profilePic = data['otherUserProfilePic'];

              // 1. Super-Safe Unread Count Logic
              // This handles Int, String, Double, or Null to prevent any crash or 0 result
              var rawCount = data['unreadCount'];
              int unreadCount = 0;

              if (rawCount is int) {
                unreadCount = rawCount;
              } else if (rawCount is String) {
                unreadCount = int.tryParse(rawCount) ?? 0;
              } else if (rawCount is double) {
                unreadCount = rawCount.toInt();
              }

              final bool hasUnread = unreadCount > 0;

              return InkWell(
                onTap: () {
                  context.push(
                    '/chat/$chatId',
                    extra: {
                      'receiverId': otherUserId,
                      'receiverName': otherUserName,
                    },
                  ).then((_) {
                    DatabaseService().markChatAsRead(currentUserId, otherUserId);
                  });
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
                          backgroundImage: profilePic != null && profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : null,
                          child: (profilePic == null || profilePic.isEmpty)
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
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (lastActivity != null)
                                  Text(
                                    _formatTimestamp(lastActivity),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: hasUnread ? theme.colorScheme.primary : Colors.grey[600],
                                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lastMessage,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: hasUnread ? theme.colorScheme.onSurface : Colors.grey[600],
                                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                // 2. Robust Badge Rendering
                                if (hasUnread)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary, // Should be blue/primary color
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    constraints: const BoxConstraints(minWidth: 20),
                                    alignment: Alignment.center,
                                    child: Text(
                                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                              ],
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
          Text('No Messages Yet', style: Theme.of(context).textTheme.headlineSmall),
        ],
      ),
    );
  }
}