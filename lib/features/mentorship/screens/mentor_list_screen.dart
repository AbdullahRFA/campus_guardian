import 'package:flutter/material.dart';
import '../models/mentor.dart';
import '../widgets/mentor_card.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  // --- DUMMY DATA ---
  // We'll replace this with real data from Firebase later.
  final List<Mentor> dummyMentors = const [
    Mentor(
      id: '1',
      name: 'Dr. Md. Ezharul Islam',
      title: 'Professor',
      company: 'Jahangirnagar University',
      profileImageUrl: 'https://via.placeholder.com/150/1976D2/FFFFFF?text=EI',
      expertise: ['Machine Learning', 'AI', 'Research'],
    ),
    Mentor(
      id: '2',
      name: 'Samsun Nahar Khandakar',
      title: 'Assistant Professor',
      company: 'Jahangirnagar University',
      profileImageUrl: 'https://via.placeholder.com/150/42A5F5/FFFFFF?text=SN',
      expertise: ['Data Structures', 'Algorithms', 'Web Dev'],
    ),
    Mentor(
      id: '3',
      name: 'Ahsin Abid',
      title: 'Lead Engineer',
      company: 'Samsung Research',
      profileImageUrl: 'https://via.placeholder.com/150/0D47A1/FFFFFF?text=AA',
      expertise: ['Mobile Dev', 'Flutter', 'Career Growth'],
    ),
  ];
  // --- END DUMMY DATA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Mentor')),
      body: ListView.builder(
        itemCount: dummyMentors.length,
        itemBuilder: (context, index) {
          final mentor = dummyMentors[index];
          return MentorCard(mentor: mentor);
        },
      ),
    );
  }
}