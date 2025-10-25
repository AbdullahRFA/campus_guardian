// features/chat/screens/chat_inbox_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your messages.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Messages'),
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // --- THIS IS THE CORRECTED PART ---
            return const Center(
              child: Text(
                'You have no messages yet.\nStart a conversation from a skill exchange post!',
                textAlign: TextAlign.center, // Property is on the Text widget
              ),
            );
          }

          final chatDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final String chatId = chatData['chatId'];
              final String otherUserId = chatData['otherUserId'];
              final String otherUserName = chatData['otherUserName'];

              return ListTile(
                leading: CircleAvatar(child: Text(otherUserName.isNotEmpty ? otherUserName[0] : 'U')),
                title: Text(otherUserName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Tap to open conversation'),
                onTap: () {
                  context.push(
                    '/chat/$chatId',
                    extra: {
                      'receiverId': otherUserId,
                      'receiverName': otherUserName,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}