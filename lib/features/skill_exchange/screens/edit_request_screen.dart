import 'package:campus_guardian/services/database_service.dart';
import 'package:campus_guardian/widgets/app_button.dart';
import 'package:campus_guardian/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../models/skill_request.dart';

class EditRequestScreen extends StatefulWidget {
  final SkillRequest request;
  const EditRequestScreen({super.key, required this.request});

  @override
  State<EditRequestScreen> createState() => _EditRequestScreenState();
}

class _EditRequestScreenState extends State<EditRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late TextEditingController _creditsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the controllers with the existing request data
    _titleController = TextEditingController(text: widget.request.title);
    _descriptionController = TextEditingController(text: widget.request.description);
    _tagsController = TextEditingController(text: widget.request.tags.join(', '));
    _creditsController = TextEditingController(text: widget.request.creditsOffered.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _updateRequest() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await DatabaseService().updateSkillRequest(
        requestId: widget.request.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: _tagsController.text.split(',').map((t) => t.trim()).toList(),
        creditsOffered: int.parse(_creditsController.text.trim()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request updated successfully!'), backgroundColor: Colors.green),
        );
        context.pop(); // Go back after saving
      }
    } catch (e) {
      // Error handling
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Request')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            AppTextField(controller: _titleController, labelText: 'Request Title'),
            const SizedBox(height: 16),
            AppTextField(controller: _descriptionController, labelText: 'Description', maxLines: 5),
            const SizedBox(height: 16),
            AppTextField(controller: _tagsController, labelText: 'Tags'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Text('Separate tags with a comma.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _creditsController,
              labelText: 'Wisdom Credits Offered',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 32),
            AppButton(
              text: _isLoading ? 'Saving...' : 'Save Changes',
              onPressed: _isLoading ? null : _updateRequest,
            ),
          ],
        ),
      ),
    );
  }
}