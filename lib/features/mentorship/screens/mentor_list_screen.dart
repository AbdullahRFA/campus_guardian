import 'package:flutter/material.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find a Mentor')),
      body: const Center(
        child: Text('List of Mentors will be shown here.'),
      ),
    );
  }
}