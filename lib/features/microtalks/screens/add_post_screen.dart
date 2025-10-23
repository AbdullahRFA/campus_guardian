import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart'; // FIXED: Changed 'package.' to 'package:'
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data()!;

      await DatabaseService().createPost(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        thumbnailUrl: _thumbnailUrlController.text.trim(),
        speakerId: user.uid,
        speakerName: userData['fullName'] ?? 'A Mentor',
        speakerTitle: userData['mentorTitle'] ?? 'Mentor',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish post: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _thumbnailUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New Post')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            AppTextField(controller: _titleController, labelText: 'Post Title'),
            const SizedBox(height: 16),
            AppTextField(controller: _thumbnailUrlController, labelText: 'Thumbnail Image URL'),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Write your content here...',
              maxLines: 10,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: _isLoading ? 'Publishing...' : 'Publish Post',
              onPressed: _isLoading ? null : _submitPost,
            ),
          ],
        ),
      ),
    );
  }
}