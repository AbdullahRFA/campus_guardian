// features/chat/screens/private_chat_screen.dart

import 'package:campus_guardian/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PrivateChatScreen extends StatefulWidget {
  final String chatId;
  // --- NEW: Add receiverId ---
  final String receiverId;
  final String receiverName;

  const PrivateChatScreen({
    super.key,
    required this.chatId,
    // --- NEW: Add receiverId to the constructor ---
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final _messageController = TextEditingController();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text;
    if (text.trim().isEmpty) return; // Don't send empty messages
    _messageController.clear(); // Clear the field immediately

    // --- MODIFIED: Call the updated DatabaseService method ---
    await DatabaseService().sendPrivateMessage(
      chatId: widget.chatId,
      text: text,
      senderId: _currentUserId,
      // Pass the receiverId to create the chat link for both users
      receiverId: widget.receiverId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.receiverName)),
      body: Column(
        children: [
          // --- MESSAGE STREAM (No changes here) ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('private_chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Start the conversation!'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final isMe = messageData['senderId'] == _currentUserId;

                    return _buildMessageBubble(
                      text: messageData['text'],
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),
          // --- MESSAGE INPUT (No changes here) ---
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String text, required bool isMe}) {
    final theme = Theme.of(context);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 24), // Added bottom padding
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}