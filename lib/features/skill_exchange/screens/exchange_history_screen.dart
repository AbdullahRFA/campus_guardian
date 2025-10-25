// features/skill_exchange/screens/exchange_history_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/exchange_post.dart';
import '../widgets/exchange_card.dart';

class ExchangeHistoryScreen extends StatelessWidget {
  const ExchangeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Post History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skill_exchange_posts')
            .where('offererId', isEqualTo: currentUserId)
            .where('status', isNotEqualTo: 'open') // Shows 'closed' posts
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- MODIFIED & CORRECTED SECTION ---
          // This single block handles both printing the error and showing a message in the UI.
          if (snapshot.hasError) {
            // This will print the full error object to your debug console
            debugPrint("History Screen Firestore Error: ${snapshot.error}");

            // This UI will be shown to the user
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          // --- END OF MODIFICATION ---

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no closed or archived posts.'));
          }

          final posts = snapshot.data!.docs.map((doc) => ExchangePost.fromFirestore(doc)).toList();

          // We can reuse the same ExchangeCard widget!
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ExchangeCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}