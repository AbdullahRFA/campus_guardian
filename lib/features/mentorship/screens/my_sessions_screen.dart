import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/session.dart';
import '../widgets/session_card.dart';

class MySessionsScreen extends StatelessWidget {
  const MySessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: StreamBuilder<QuerySnapshot>(
        // The query: get sessions where the user is a participant
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('participants', arrayContains: currentUserId)
            .orderBy('createdAt', descending: true) // Show newest first
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no booked sessions.'));
          }

          final sessionDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sessionDocs.length,
            itemBuilder: (context, index) {
              final session = Session.fromFirestore(sessionDocs[index]);
              return SessionCard(session: session);
            },
          );
        },
      ),
    );
  }
}