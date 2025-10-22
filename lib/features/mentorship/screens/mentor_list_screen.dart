import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../widgets/mentor_card.dart';

class MentorListScreen extends StatelessWidget {
  // MODIFIED: Added a final variable to hold the list of mentors.
  final List<Mentor> mentors;

  // MODIFIED: Updated the constructor to accept the 'mentors' parameter.
  const MentorListScreen({super.key, required this.mentors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Mentor')),
      body: ListView.builder(
        // Use the 'mentors' list that was passed in.
        itemCount: mentors.length,
        itemBuilder: (context, index) {
          final mentor = mentors[index];
          return MentorCard(mentor: mentor);
        },
      ),
    );
  }
}