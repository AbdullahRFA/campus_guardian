import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This AppBar will automatically show a back button
      // because we navigated to this screen from another one.
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