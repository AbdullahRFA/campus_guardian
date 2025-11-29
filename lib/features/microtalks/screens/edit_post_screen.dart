import 'package:campus_guardian/features/microtalks/models/post.dart';
import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _thumbnailUrlController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _thumbnailUrlController = TextEditingController(text: widget.post.thumbnailUrl);
    _descriptionController = TextEditingController(text: widget.post.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _thumbnailUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await DatabaseService().updatePost(
        postId: widget.post.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        thumbnailUrl: _thumbnailUrlController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop(); // Return to the previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
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
              text: _isLoading ? 'Saving...' : 'Save Changes',
              onPressed: _isLoading ? null : _updatePost,
            ),
          ],
        ),
      ),
    );
  }
}