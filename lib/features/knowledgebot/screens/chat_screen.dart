import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JU KnowledgeBot'),
      ),
      body: Center(
        child: Text(
          'The AI chat interface will be built here.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}