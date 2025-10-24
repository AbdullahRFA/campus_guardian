import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _creditsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  // MODIFIED: This method now saves the request to Firebase
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      final requesterName = userDoc.data()?['fullName'] ?? 'A Student';

      // Prepare the data from the form
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final credits = int.tryParse(_creditsController.text.trim()) ?? 0;
      final tags = _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();

      // Call the database service to create the document
      await DatabaseService().createSkillRequest(
        title: title,
        description: description,
        tags: tags,
        creditsOffered: credits,
        requesterId: currentUser.uid,
        requesterName: requesterName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your request has been posted!'), backgroundColor: Colors.green),
        );
        context.pop(); // Go back to the skill exchange feed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post request: $e'), backgroundColor: Colors.red),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Create a New Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            AppTextField(
              controller: _titleController,
              labelText: 'Request Title',
              hintText: 'e.g., Need help with a Java assignment',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Describe the problem in detail...',
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _tagsController,
              labelText: 'Tags',
              hintText: 'e.g., Java, OOP, Data Structures',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text('Separate tags with a comma.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _creditsController,
              labelText: 'Wisdom Credits Offered',
              hintText: 'e.g., 20',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 32),
            AppButton(
              text: _isLoading ? 'Posting...' : 'Post Request',
              onPressed: _isLoading ? null : _submitRequest,
            ),
          ],
        ),
      ),
    );
  }
}