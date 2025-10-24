import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/skill_request.dart';
import '../widgets/request_card.dart';

class SkillExchangeScreen extends StatelessWidget {
  const SkillExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Exchange')),
      body: StreamBuilder<QuerySnapshot>(
        // Query the 'skill_requests' collection, ordered by most recent
        stream: FirebaseFirestore.instance
            .collection('skill_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No skill requests have been posted yet.'));
          }

          // Map the documents to SkillRequest objects
          final requests = snapshot.data!.docs.map((doc) => SkillRequest.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return RequestCard(request: requests[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/app/skill-exchange/create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Post a new request',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}