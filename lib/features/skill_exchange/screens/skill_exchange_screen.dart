import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/exchange_post.dart';
import '../widgets/exchange_card.dart';

class SkillExchangeScreen extends StatelessWidget {
  const SkillExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Exchange'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My Post History',
            onPressed: () {
              context.push('/app/skill-exchange/history');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('skill_exchange_posts')
            .where('status', isEqualTo: 'open')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- MODIFIED SECTION ---
          if (snapshot.hasError) {
            // This line will print the detailed error to your debug console
            debugPrint("Firestore Error: ${snapshot.error}");

            // This will still show a user-friendly message in the UI
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          // --- END OF MODIFICATION ---
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No exchange offers have been posted yet.'));
          }

          final posts = snapshot.data!.docs.map((doc) => ExchangePost.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ExchangeCard(post: posts[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/app/skill-exchange/create'),
        child: const Icon(Icons.add),
        tooltip: 'Post a new offer',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}