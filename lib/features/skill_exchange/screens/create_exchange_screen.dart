import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateExchangeScreen extends StatefulWidget {
  const CreateExchangeScreen({super.key});

  @override
  State<CreateExchangeScreen> createState() => _CreateExchangeScreenState();
}

class _CreateExchangeScreenState extends State<CreateExchangeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the "Offer" section
  final _offerTitleController = TextEditingController();
  final _offerDescriptionController = TextEditingController();
  final _offerTagsController = TextEditingController();

  // Controllers for the "Request" section
  final _requestTitleController = TextEditingController();
  final _requestDescriptionController = TextEditingController();
  final _requestTagsController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _offerTitleController.dispose();
    _offerDescriptionController.dispose();
    _offerTagsController.dispose();
    _requestTitleController.dispose();
    _requestDescriptionController.dispose();
    _requestTagsController.dispose();
    super.dispose();
  }

  // MODIFIED: This method now saves the exchange post to Firebase
  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final offererName = userDoc.data()?['fullName'] ?? 'A User';

      // Call the new database service method with data from all controllers
      await DatabaseService().createExchangePost(
        offererId: currentUser.uid,
        offererName: offererName,
        offerTitle: _offerTitleController.text.trim(),
        offerDescription: _offerDescriptionController.text.trim(),
        offerTags: _offerTagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
        requestTitle: _requestTitleController.text.trim(),
        requestDescription: _requestDescriptionController.text.trim(),
        requestTags: _requestTagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exchange offer posted successfully!'), backgroundColor: Colors.green),
        );
        context.pop(); // Go back to the previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post offer: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create an Exchange Post')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- OFFER SECTION ---
            Text('I Can Teach...', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            AppTextField(controller: _offerTitleController, labelText: 'Skill Title', hintText: 'e.g., Advanced Flutter State Management'),
            const SizedBox(height: 16),
            AppTextField(controller: _offerDescriptionController, labelText: 'Description', hintText: 'Describe what you will teach...', maxLines: 4),
            const SizedBox(height: 16),
            AppTextField(controller: _offerTagsController, labelText: 'Tags', hintText: 'e.g., Flutter, State Management, Dart'),
            const Divider(height: 48),

            // --- REQUEST SECTION ---
            Text('In Return, I Want to Learn...', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            AppTextField(controller: _requestTitleController, labelText: 'Skill Title', hintText: 'e.g., Help with Data Structures'),
            const SizedBox(height: 16),
            AppTextField(controller: _requestDescriptionController, labelText: 'Description', hintText: 'Describe what you need help with...', maxLines: 4),
            const SizedBox(height: 16),
            AppTextField(controller: _requestTagsController, labelText: 'Tags', hintText: 'e.g., DSA, Algorithms, Java'),
            const SizedBox(height: 32),

            // --- SUBMIT BUTTON ---
            AppButton(
              text: _isLoading ? 'Posting...' : 'Post Exchange Offer',
              onPressed: _isLoading ? null : _submitPost,
            ),
          ],
        ),
      ),
    );
  }
}