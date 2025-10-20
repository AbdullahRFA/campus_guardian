// lib/features/knowledgebot/widgets/message_input_field.dart
import 'package:flutter/material.dart';

class MessageInputField extends StatefulWidget {
  final Function(String) onSendMessage;
  const MessageInputField({super.key, required this.onSendMessage});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
      FocusScope.of(context).unfocus(); // Hide keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _handleSend,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}