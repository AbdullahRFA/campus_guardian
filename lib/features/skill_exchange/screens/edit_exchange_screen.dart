import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/exchange_post.dart';

class EditExchangeScreen extends StatefulWidget {
  final ExchangePost post;
  const EditExchangeScreen({super.key, required this.post});

  @override
  State<EditExchangeScreen> createState() => _EditExchangeScreenState();
}

class _EditExchangeScreenState extends State<EditExchangeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _offerTitleController;
  late TextEditingController _offerDescriptionController;
  late TextEditingController _offerTagsController;
  late TextEditingController _requestTitleController;
  late TextEditingController _requestDescriptionController;
  late TextEditingController _requestTagsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing post data
    _offerTitleController = TextEditingController(text: widget.post.offerTitle);
    _offerDescriptionController = TextEditingController(text: widget.post.offerDescription);
    _offerTagsController = TextEditingController(text: widget.post.offerTags.join(', '));
    _requestTitleController = TextEditingController(text: widget.post.requestTitle);
    _requestDescriptionController = TextEditingController(text: widget.post.requestDescription);
    _requestTagsController = TextEditingController(text: widget.post.requestTags.join(', '));
  }

  @override
  void dispose() {
    // Dispose all the correct controllers
    _offerTitleController.dispose();
    _offerDescriptionController.dispose();
    _offerTagsController.dispose();
    _requestTitleController.dispose();
    _requestDescriptionController.dispose();
    _requestTagsController.dispose();
    super.dispose();
  }

  Future<void> _updatePost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await DatabaseService().updateExchangePost(
        postId: widget.post.id,
        offerTitle: _offerTitleController.text.trim(),
        offerDescription: _offerDescriptionController.text.trim(),
        offerTags: _offerTagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        requestTitle: _requestTitleController.text.trim(),
        requestDescription: _requestDescriptionController.text.trim(),
        requestTags: _requestTagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update offer: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exchange Post')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- OFFER SECTION ---
            Text('I Can Teach...', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            AppTextField(controller: _offerTitleController, labelText: 'Skill Title'),
            const SizedBox(height: 16),
            AppTextField(controller: _offerDescriptionController, labelText: 'Description', maxLines: 4),
            const SizedBox(height: 16),
            AppTextField(controller: _offerTagsController, labelText: 'Tags (comma separated)'),
            const Divider(height: 48),

            // --- REQUEST SECTION ---
            Text('In Return, I Want to Learn...', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            AppTextField(controller: _requestTitleController, labelText: 'Skill Title'),
            const SizedBox(height: 16),
            AppTextField(controller: _requestDescriptionController, labelText: 'Description', maxLines: 4),
            const SizedBox(height: 16),
            AppTextField(controller: _requestTagsController, labelText: 'Tags (comma separated)'),
            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
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