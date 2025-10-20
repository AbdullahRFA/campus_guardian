// lib/features/knowledgebot/screens/chat_screen.dart
import 'dart:convert';
import 'package:campus_guardian/services/ai_bot_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final AiBotService _aiBotService = AiBotService();

  List<Map<String, String>> messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString("chat_history");
    if (stored != null) {
      final decoded = jsonDecode(stored) as List;
      setState(() {
        messages = decoded.map((item) => Map<String, String>.from(item as Map)).toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("chat_history", jsonEncode(messages));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _scrollToBottom();

    final aiResponse = await _aiBotService.getResponse(text);

    setState(() {
      messages.add({"role": "ai", "text": aiResponse});
      _isLoading = false;
    });
    _scrollToBottom();
    _saveMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JU KnowledgeBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == messages.length) {
                  return const ChatBubble(role: "typing", text: "...");
                }
                final msg = messages[index];
                return ChatBubble(role: msg["role"]!, text: msg["text"]!);
              },
            ),
          ),
          MessageInputField(onSendMessage: _sendMessage),
        ],
      ),
    );
  }
}