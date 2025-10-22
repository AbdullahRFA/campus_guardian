import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../widgets/mentor_card.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Mentor')),
      // Use a StreamBuilder to listen for live data
      body: StreamBuilder<QuerySnapshot>(
        // The query: get all users who have marked themselves as available
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('isMentorAvailable', isEqualTo: true)
            .snapshots(),

        builder: (context, snapshot) {
          // Show a loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if something goes wrong
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          // Show a message if no mentors are available
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No mentors are available right now.'));
          }

          // If we have data, get the list of documents
          final mentorDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: mentorDocs.length,
            itemBuilder: (context, index) {
              // Create a Mentor object from each document
              final mentor = Mentor.fromFirestore(mentorDocs[index]);
              return MentorCard(mentor: mentor);
            },
          );
        },
      ),
    );
  }
}