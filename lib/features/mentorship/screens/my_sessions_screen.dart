import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/session.dart';
import '../widgets/session_card.dart';

// MODIFIED: Converted to a StatefulWidget
class MySessionsScreen extends StatefulWidget {
  const MySessionsScreen({super.key});

  @override
  State<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends State<MySessionsScreen> {
  // NEW: State variable to hold the user ID
  String? _userId;

  // NEW: initState is called once when the widget is created
  @override
  void initState() {
    super.initState();
    // Get the user ID and store it in our state variable
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    // NEW: A check to handle the case where the user ID isn't available yet
    if (_userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Sessions')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: StreamBuilder<QuerySnapshot>(
        // MODIFIED: Use the reliable _userId state variable for the query
        stream: FirebaseFirestore.instance
            .collection('sessions')
            .where('participants', arrayContains: _userId)
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