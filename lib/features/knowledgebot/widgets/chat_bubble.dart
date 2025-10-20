// lib/features/knowledgebot/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'typing_indicator.dart';

class ChatBubble extends StatelessWidget {
  final String role;
  final String text;

  const ChatBubble({super.key, required this.role, required this.text});

  @override
  Widget build(BuildContext context) {
    final isUser = role == "user";
    final isTyping = role == "typing";
    final theme = Theme.of(context);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary.withOpacity(0.2) : theme.colorScheme.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isTyping
            ? const TypingIndicator()
            : GptMarkdown(text, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}