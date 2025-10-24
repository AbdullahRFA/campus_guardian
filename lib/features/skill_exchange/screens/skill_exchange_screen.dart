import 'package:flutter/material.dart';
import '../models/skill_request.dart';
import '../widgets/request_card.dart';

class SkillExchangeScreen extends StatelessWidget {
  const SkillExchangeScreen({super.key});

  // Dummy data for skill requests
  final List<SkillRequest> dummyRequests = const [
    const SkillRequest(
      id: '1',
      title: 'Need help with a Flutter project bug',
      description: 'I\'m stuck on a state management issue with my final year project. The provider is not updating the UI correctly. Looking for someone with experience in Flutter state management.',
      requesterName: 'Abdullah Nazmus-Sakib',
      creditsOffered: 50,
      tags: ['Flutter', 'State Management'],
    ),
    const SkillRequest(
      id: '2',
      title: 'Help with Data Structures final exam prep',
      description: 'Looking for a senior who can help me review key concepts like graphs, trees, and dynamic programming before my final exam next week.',
      requesterName: 'A Student',
      creditsOffered: 30,
      tags: ['Algorithms', 'Exam Prep'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Exchange')),
      body: ListView.builder(
        itemCount: dummyRequests.length,
        itemBuilder: (context, index) {
          return RequestCard(request: dummyRequests[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We'll navigate to a "Create Request" screen later
        },
        child: const Icon(Icons.add),
        tooltip: 'Post a new request',
      ),
    );
  }
}